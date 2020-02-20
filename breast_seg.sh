#!/usr/bin/env bash
# 
# -*- coding: utf-8 -*-
# title           : breast_seg.sh
# description     : [description]
# author          : Adebayo B. Braimah
# e-mail          : adebayo.braimah@cchmc.org
# date            : 2020 02 20 17:57:51
# version         : 0.0.1
# usage           : breast_seg.sh [-h,--help]
# notes           : [notes]
# bash_version    : 5.0.7
#==============================================================================

#
# Define Usage & (Miscellaneous) Function(s)
#==============================================================================

Usage() {
  cat << USAGE

  Usage: $(basename ${0}) -d <DICOM> -o <OUT_DIR> -s <ID>

Wrapper script for the automated MATLAB based 3D breast segmentation software DeepSeA.

Edits were made in the source code to read Philips MR image DICOM tags.


Please cite: 

  Wei, D., Weinstein, S., Hsieh, M. K., Pantalone, L., & Kontos, D. (2018). Three-Dimensional 
  Whole Breast Segmentation in Sagittal and Axial Breast MRI With Dense Depth Field Modeling 
  and Localized Self-Adaptation for Chest-Wall Line Detection. IEEE Transactions on Biomedical 
  Engineering, 66(6), 1567-1579.

Source code was obtained from this git repository: https://github.com/CBICA/DeepSeA

Required arguments:

-d,--dicom-dir      Subject's DICOM directory
-o,--out-dir        Output directory (does not need to exist at runtime)
-s,--sub-id         Input subject ID

Optional arguments:

--orientation       Input image orientation ('ax' or 'sag') [default: ax]
--voxel-size        Isotopric voxel-size (in mm, float) [default: 1]
--lateral-bounds    Estimate lateral bounds [default: false]
--medial-bounds     Estimate medial bounds [default: false]
--bottom-bounds     Estimate bottom boundary [default: false]

----------------------------------------

-h,-help,--help 		Prints usage and exits.

NOTE: 
- Creates a spreadsheet to aggregrate results
- Creates subject video of segmentation images

----------------------------------------

Adebayo B. Braimah - 2020 02 20 17:57:51

$(basename ${0}) v0.0.1

----------------------------------------

  Usage: $(basename ${0}) -d <DICOM> -o <OUT_DIR> -s <ID>

USAGE
  exit 1
}

#
# Define Logging Function(s)
#==============================================================================

# Echoes status updates to the command line
echo_color(){
  msg='\033[0;'"${@}"'\033[0m'
  # echo -e ${msg} >> ${stdOut} 2>> ${stdErr}
  echo -e ${msg} 
}
echo_red(){
  echo_color '31m'"${@}"
}
echo_green(){
  echo_color '32m'"${@}"
}
echo_blue(){
  echo_color '36m'"${@}"
}

exit_error(){
  echo_red "${@}"
  exit 1
}

# log function for completion
run()
{
  echo "${@}"
  "${@}" >>${log} 2>>${err}
  if [ ! ${?} -eq 0 ]; then
    echo "failed: see log files ${log} ${err} for details"
    exit 1
  fi
  echo "-----------------------"
}

if [ ${#} -lt 1 ]; then
  Usage >&2
  exit 1
fi

#
# Parse arguments
#==============================================================================

# Set defaults
scripts_dir=$(dirname $(realpath ${0}))
orientation=""
voxel=1
lat_bnds=""
bot_bnds=""
med_bnds=""

# Parse options
while [ ${#} -gt 0 ]; do
  case "${1}" in
    -d|--dicom-dir) shift; dicom_dir=${1} ;;
    -o|--out-dir) shift; results_dir=${1} ;;
    -s|--sub-id) shift; sub_id=${1} ;;
    --orientation) shift; orientation=${1} ;;
    --voxel-size) shift; voxel=${1} ;;
    --lateral-bounds) lat_bnds=true ;;
    --medial-bounds) med_bnds=true ;;
    --bottom-bounds) bot_bnds=true ;;
    -h|-help|--help) Usage; ;;
    -*) echo_red "$(basename ${0}): Unrecognized option ${1}" >&2; Usage; ;;
    *) break ;;
  esac
  shift
done

#
# Check dependencies
#==============================================================================

if ! hash matlab 2>/dev/null; then
  echo ""
  echo_red "MATLAB is not installed or in the system path. Exiting..."
  echo ""
  exit 1
fi

if ! hash python3 2>/dev/null; then
  echo ""
  echo_red "Python v3.0+ is not installed or in the system path. Exiting..."
  echo ""
  exit 1
fi

if ! hash ffmpeg 2>/dev/null; then
  echo ""
  echo_red "ffmpeg is not installed or in the system path. Exiting..."
  echo ""
  exit 1
fi

#
# Check arguments
#==============================================================================

# Required arguments
if [[ -z ${dicom_dir} ]] || [[ ! -d ${dicom_dir} ]]; then
  echo_red "Input error: Subject T1w non-fat suppressed DICOM directory required. Exiting..."
  exit 1
else
  dicom_dir=$(realpath ${dicom_dir})
fi

if [[ -z ${results_dir} ]]; then
  echo_red "Input error: No output directory specified. Exiting..."
  exit 1
fi

if [[ -z ${sub_id} ]]; then
  echo_red "Input error: No subject ID specified. Exiting..."
  exit 1
fi

# Optional arguments
if [ ! -z ${voxel} ]; then
  if ! [[ "${voxel}" =~ ^[+-]?[0-9]+\.?[0-9]*$ ]]; then
          echo_red "voxel-size argument requires floats [1.0-9999999.0]"
          exit 1
  fi
fi

#
# Construct arguments
#==============================================================================

cmd=""

if [[ ${orientation,,} = "axial" ]] || [[ ${orientation,,} = "ax" ]]; then
  cmd+=",'orientation','ax'"
elif [[ ${orientation,,} = "sagittal" ]] || [[ ${orientation,,} = "sag" ]]; then
  cmd+=",'orientation','sag'"
elif [[ ${orientation} = "" ]]; then
  cmd=""
else
  echo_red "Unknown argument passed to orientation. Acceptable arguments are either axial or sagittal."
  exit 1
fi

if [[ ! -z ${voxel} ]]; then
  cmd+=",'vs','${voxel}'"
fi

if [[ ${lat_bnds,,} = "true" ]] && [[ ${orientation,,} = "sag" ]]; then
  cmd+=",'latBnds','${lat_bnds}'"
elif [[ ${lat_bnds,,} = "false" ]] && [[ ${orientation,,} = "ax" ]]; then
  cmd+=",'latBnds','${lat_bnds}'"
fi

if [[ ${bot_bnds,,} = "true" ]]; then
  cmd+=",'botBnds','${bot_bnds}'"
fi

if [[ ${med_bnds,,} = "true" ]]; then
  cmd+=",'medBnds','${med_bnds}'"
fi

#
# Run DeepSeA breast segmentation software
#==============================================================================

# Check that dicom_dir has no hidden DICOM files
hidden_files=( $(cd ${dicom_dir}; ls -a $(pwd)/.*.dcm) )

if [[ ${#hidden_files[@]} -gt 0 ]]; then
  rm ${hidden_files[@]}
fi

# Run software
# ${MATLABPATH}/matlab -nodesktop -nosplash -r "breastSegSetup('${dicom_dir}', '${results_dir}', '${sub_id}' ${cmd})"
matlab -nodesktop -nosplash -r "breastSegSetup('${dicom_dir}', '${results_dir}', '${sub_id}' ${cmd})"

# Get the necessary input/output files
mat_file=$(ls ${results_dir}/${sub_id}/*${sub_id}*.mat)
csv_file=${results_dir}/cohort_results.csv
img_dir=${results_dir}/${sub_id}/wholeBreast
vid_out=${results_dir}/cohort_seg/${sub_id}_seg_vid.mp4

if [[ -d ${results_dir}/cohort_seg ]]; then
  mkdir -p ${results_dir}/cohort_seg
fi

${scripts_dir}/read_seg.py --mat-file=${mat_file} --csv-file=${csv_file} --make-mp4 --pic-dir=${img_dir} --vid=${vid_out}
