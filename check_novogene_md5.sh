#!/bin/sh

#SBATCH --partition=<partition>
#SBATCH --mail-user=<email>
#SBATCH --out <filepath/checkMD5sums.log>


#===============================================================================
# A short script to check the MD5sum of the novogene files in a loop

# Novogene send data with the folder structure 
# 01.RawData
#   -> Sample_1
#       -> sample1_fwd.fq.gz 
#       -> sample1_rev.fq.gz
#       -> MD5.txt 
# This only works where the file structure is the same. 
# It assumes the MD5.txt file provided is a list of MD5 checksum values in alphabetical order of sequencing file names.

#================================================================================
# set RAWDATADIR wherever the 01.RawData folder is:
RAWDATADIR=<filepath/01.RawData>
#=================================================================================

for sample in $(ls $RAWDATADIR);

do

echo "Checking files for ${sample}"
SAMPLEPATH=$RAWDATADIR/$sample
cd $SAMPLEPATH

if [ -e myMD5sum.txt ]; then
echo "Removing previous myMD5sum.txt file"
rm myMD5sum.txt # remove any existing "myMD5sum.txt" files from previous runs
fi

for seqfile in $(ls $SAMPLEPATH/*fq.gz);

do

echo "checking $seqfile"
md5sum $seqfile >> myMD5sum.txt

done

echo "checking difference between MD5sums"

novogeneMD5=$(cut -c 1-32 MD5.txt)
myMD5=$(cut -c 1-32 myMD5sum.txt)

if [ "$novogeneMD5" = "$myMD5" ]; then
    echo "MD5sums matched"
else
    echo "MD5sums failed to match...exiting"
    exit 1
fi

done  
 