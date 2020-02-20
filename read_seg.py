#!/usr/bin/env python3
# 
# -*- coding: utf-8 -*-
# title           : read_seg.py
# description     : [description]
# author          : Adebayo B. Braimah
# e-mail          : adebayo.braimah@cchmc.org
# date            : 2020 02 20 15:03:07
# version         : 0.0.1
# usage           : read_seg.py [-h,--help]
# notes           : [notes]
# python_version  : 3.7.3
#==============================================================================

# Define usage
"""

Python script intended to read the output MATLAB files from DeepSeA and aggregate those results into a spreadsheet.
If the spreadsheet does not exist at runtime, then it is created. If it does exist, then it is appended to.

Additionally, this script also can create videos for each subject (provided ffmpeg is installed and added to the system
path).

Usage:
    read_seg.py [video options | options] [required arguments]

Required arguments:
    -m,--mat-file MAT   Input '.mat' file from DeepSeA
    -c,--csv-file CSV   Output csv file with extension

Video arguments:
    --make-mp4       Enables option to create mp4 video of subject's segmentation images
    -p,--pic-dir DIR    Image directory path for that specific subject's images
    -v,--vid MP4        Output mp4 video name
    -f,--framerate INT  Framerate of output video (in frames per second) [default: 10]

Optional arguments:
    -h,--help           Prints help menu, then exits
    --version        Prints version, then exits

NOTE: MP4 related options require that ffmpeg be installed and added to system path.

"""

# Import packages/modules
import pandas as pd
import mat73
import subprocess
import sys
import os

# Import packages and modules for argument parsing
from docopt import docopt

# Define functions
def write_data_csv(mat_file, csv_file):
    '''
    Creates CSV spreadsheet for automated breast segmentation provided the segmentation data MATLAB output file.
    If the spreadsheet does not exist at runtime, it will be created. If the spreadsheet does exist, then it is
    appended to.

    NOTE: This function requires the mat73 module - as this reads MATLAB structures produced by MATLAB v7.3+.
        See the github page for further details: https://github.com/skjerns/mat7.3

    Arguments:
        mat_file (MATLAB .mat file): Segmentation data MATLAB output file (from DeepSeA)
        csv_file (csv file): Output csv filename (with extension)

    Returns:
        csv_file (csv file): Output csv filename (with extension) with appended data/information
    '''

    # Load and read mat file
    data_dict = mat73.loadmat(mat_file)

    # Store necessary data from dict
    sub_id = data_dict['segdata']['ID']
    vol_R = data_dict['segdata']['VT1']  # right
    vol_L = data_dict['segdata']['VT2']  # left
    vol_T = data_dict['segdata']['VT']  # both

    # Create CSV output dict
    csv_dict = {"Subject ID": [sub_id],
                "Right Breast Volume (cm\u00b3)": [vol_R],
                "Left Breast Volume (cm\u00b3)": [vol_L],
                "Total Breast Volume (cm\u00b3)": [vol_T]}

    # Create dataframe
    df = pd.DataFrame.from_dict(csv_dict, orient='columns')

    # Write to file
    if os.path.exists(csv_file):
        df.to_csv(csv_file, sep=",", header=False, index=False, mode='a')
    else:
        df.to_csv(csv_file, sep=",", header=True, index=False, mode='w')

    return csv_file


def vid_from_pics(pic_dir, vid, frame_rate=10, init_pattern=""):
    '''
    Creates a video from a directory of sequentially named/numbered images.

    NOTE: Requires that 'ffmpeg' is installed and added to the system path.

    Arguments:
        pic_dir (image directory): Input picture directory
        vid (mp4 file): Output file name (with extension)
        frame_rate (int): Frame rate (frames per second)
        init_pattern (str): Pattern to search sequentially numbered/named images

    Returns:
        vid (mp4 file): Output mp4
    '''

    # Init command list
    cmd_list = ["ffmpeg"]
    cmd_list.append("-y")  # File overwrite option enabled by default

    # Append inputs
    cmd_list.append("-i")
    cmd_list.append(f"{pic_dir}/%{init_pattern}03d.jpg")

    # Append options
    cmd_list.append("-framerate")
    cmd_list.append(f"{frame_rate}")

    # Append output filename
    cmd_list.append(f"{vid}")

    # Perform/Execute command
    subprocess.call(cmd_list)

def which(program):
    '''
    Mimics UNIX which command.

    Arguments:
        program (string): Input program/executable name as a string

    Returns:
        program, exe_file, or None: Searches system path and returns the requested executable/file. If it does not exist, None is returned.
    '''

    def is_exe(fpath):
        return os.path.isfile(fpath) and os.access(fpath, os.X_OK)

    fpath, fname = os.path.split(program)
    if fpath:
        if is_exe(program):
            return program
    else:
        for path in os.environ["PATH"].split(os.pathsep):
            exe_file = os.path.join(path, program)
            if is_exe(exe_file):
                return exe_file

    return None

if __name__ == '__main__':

    # Parse arguments
    args = docopt(__doc__, help=True, version=f'{__file__} v0.0.1', options_first=False)
    # print(args)

    # Check for required arguments
    if not args['--mat-file'] and not args['--csv-file']:
        print("")
        print(f"Usage:   {__file__} --mat-file MAT --csv-file CSV   |   -h,-help,--help")
        print("")
        print("Please see help menu for details.")
        print("")
        sys.exit(1)

    # Check if make mp4 option was used
    if args['--make-mp4']:
        ffmpeg_install = which('ffmpeg')
        if not ffmpeg_install:
            print("")
            print("ffmpeg is not installed on this system or added to system path. This option cannot be used. Exiting...")
            print("")
            sys.exit(1)

        if not args['--pic-dir']:
            print("")
            print("Create mp4 option was enabled but no image directory was specified. Exiting...")
            print("")
            sys.exit(1)

        if not args['--vid']:
            print("")
            print("Create mp4 option was enabled but no output mp4 name was specified. Exiting...")
            print("")
            sys.exit(1)

    # Create spreadsheet
    print("")
    print("Writing subject's data to spreadsheet")
    print("")
    csv_file = write_data_csv(mat_file=args['--mat-file'],csv_file=args['--csv-file'])

    # Create mp4 if required
    if args['--make-mp4']:
        print("")
        print("Creating subject segmentation video")
        print("")
        mp4_vid = vid_from_pics(pic_dir=args['--pic-dir'],vid=args['--vid'],frame_rate=args['--framerate'],init_pattern="")
