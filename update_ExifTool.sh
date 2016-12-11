#!/bin/bash

# This is a bash script intends to download and update the files of ExifTool
# automatically for Mac OS, I think it will work on GNU/Linux too,
# because most of the commands are GNU versions.
# This is my first 'long' bash script. I am still learning, you're
# welcome to leave the advices and suggestions.

# Use curl to download the file
# curl "http://owl.phy.queensu.ca/~phil/exiftool/Image-ExifTool-*.tar.gz" >\
#    ~/Downloads/Image-ExifTool.tar.gz

# Don't know how to get the latest file from the website.
# Just download the file by using the internet browser first and put 
# it under ~/Downloads directory.

# Pre-defind variables
# Get the source file checksum value, here I use sha1 value of the gz file.
originsha1sum=`/usr/local/bin/wget -O- -q \
    http://owl.phy.queensu.ca/~phil/exiftool/checksums.txt \
    |grep -i sha1.*gz |awk '{ FS = "= "} { print $2}'`
# Get the path and name of downloaded file.
downloadedfile=`find ~/Downloads -iname 'Image-Exif*.tar.gz' -print|sort \
    -rn|head -1`
# Get the file path.
filedir=`/usr/bin/dirname $downloadedfile`
# Get the name of the file.
filename=`/usr/bin/basename $downloadedfile`
# Calculate the sha1 checksum value of the downloaded file.
calsha1sum=`/usr/bin/shasum $downloadedfile |awk '{print $1}'`
# The directory of the files to be updated.
targetdir=/usr/local/bin

# Compare shasums
if [ "$originsha1sum" == "$calsha1sum" ]; then
    /bin/echo "File checksum OK, proceed to decompress the file\n"

    # Decompress the downloaded file if checksum value is correct.
    /usr/local/bin/gtar xvzf $downloadedfile -C $filedir \
        > $filedir/tarcontent && echo "File Decompressed\n" 
    tardir=`/usr/local/bin/greadlink -f $(head -1 $filedir/tarcontent)` 
    /bin/rm $filedir/tarcontent

    # Update files under /usr/local/bin, following the instructions
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
    echo "Checksum not correct, exit now" && exit 0
fi
