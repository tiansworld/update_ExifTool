#!/bin/bash

# This is a bash script intends to download and update the files of ExifTool
# automatically for Mac OS, I think it will work on GNU/Linux too,
# because most of the commands are GNU versions. But you should change the
# commands path first.
# I suppose you have Homebrew installed on your machine.

# This is my first 'long' bash script. I am still learning, you're
# welcome to leave the advices and suggestions.

# Download Image-ExifTool
echo "Checking Version Number"
vernumber=`/usr/local/opt/curl/bin/curl https://www.exiftool.org/ver.txt` 
echo "Downloading"
cd ~/Downloads && /usr/local/bin/wget  https://www.exiftool.org/Image-ExifTool-$vernumber.tar.gz

# Checksum
# Get the source file checksum value, here I use sha1 value of the gz file.
originsha1sum=`/usr/local/bin/wget -O- -q \
    https://www.exiftool.org/checksums.txt \
    |grep -i "^SHA1.*$vernumber.tar.gz" |awk '{ FS = "= "} { print $2}'`
# Get the path and name of downloaded file.
downloadedfile=~/Downloads/Image-ExifTool-$vernumber.tar.gz
# Get the file path.
filedir=`/usr/bin/dirname $downloadedfile`
# Get the name of the file.
filename=`/usr/bin/basename $downloadedfile`
# Calculate the sha1 checksum value of the downloaded file.
calsha1sum=`/usr/bin/shasum $downloadedfile |awk '{print $1}'`
# The directory of the files to be updated.
targetdir=/usr/local/bin

# Compare shasums
echo "Downloaded file sum is: $calsha1sum"
echo "The sha1 checksum should be: $originsha1sum"

if [ "$originsha1sum" == "$calsha1sum" ]; then
    /bin/echo "File checksums are the same, proceed to decompress the file"
    # Decompress the downloaded file if checksum value is correct.
    /usr/local/bin/gtar xvzf $downloadedfile -C $filedir \
         --index-file=$filedir/tarcontent && echo "File Decompressed" 
    tardir=`/usr/local/bin/greadlink -f $(printf $filedir"/"$(head -1 $filedir/tarcontent))` 
    #Added printf to get the full path of the decompressed directory
    #So the script can be called under any directory.
    /bin/rm $filedir/tarcontent

# Update files under /usr/local/bin, by following the instructions
# at http://owl.phy.queensu.ca/~phil/exiftool/install.html
    if [ -w /usr/local/bin ]; then
        /bin/cp -r $tardir/exiftool $tardir/lib $targetdir &&\
            /bin/echo "OK, update complete.\n" && exit 0
    else
        /bin/echo "Permission denied, trying sudo"
        /usr/bin/sudo /bin/cp -r $tardir/exiftool $tardir/lib \
            $targetdir && /bin/echo "OK, update complete.\n" && exit 0
    fi

else
    echo "The downloaded file checksum is not correct, exit now" && exit 0
fi
