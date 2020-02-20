#!/usr/bin/env bash

scripts_dir=$(dirname $(realpath ${0}))

d=/Volumes/Adebayo_SSD/files.back-up/KimtoAdebayo/Breast_Density/IRC10_BREASTTEST_22AUG2013/20130822/501_T1_WO_FAT_SAT_013082214145554289
o=/Users/brac4g/Desktop/DeepSeA/test_results
s="sub-0009"
voxel_size=1

${scripts_dir}/breast_seg.sh -d ${d} -o ${o} -s ${s} --voxel-size ${voxel_size}