#!/usr/bin/env bash

scripts_dir=$(dirname $(realpath ${0}))

# # test variables 1
# d=/Volumes/Adebayo_SSD/files.back-up/KimtoAdebayo/Breast_Density/IRC10_BREASTTEST_22AUG2013/20130822/501_T1_WO_FAT_SAT_013082214145554289
# o=/Users/brac4g/Desktop/DeepSeA/test_results
# s="sub-0009"
# voxel_size=1
# 
# ${scripts_dir}/breast_seg.sh -d ${d} -o ${o} -s ${s} --voxel-size ${voxel_size}

# # Create file lists
# parent_dir=/Volumes/Adebayo_SSD/files.back-up/KimtoAdebayo/Breast_Density
# dirs=( $(cd ${parent_dir}; ls -d $(pwd)/*/*/*T1*WO*FAT*SAT*) )

# for dir in ${dirs[@]}; do
#   echo ${dir} >> dicom_dir_list.txt
# done

# variables
dir_list=/Users/brac4g/Desktop/DeepSeA/dicom_dir_list.txt
sub_list=/Users/brac4g/Desktop/DeepSeA/sub_list.txt
out_dir=${scripts_dir}/sample_data
voxel_size=0.6

# create subject arrays
mapfile -t dirs < ${dir_list}
mapfile -t subs < ${sub_list}

for ((i = 0; i < ${#subs[@]}; i++)); do
  ${scripts_dir}/breast_seg.sh --dicom-dir ${dirs[$i]} --out-dir ${out_dir} --sub-id ${subs[$i]} # --voxel-size ${voxel_size}
done