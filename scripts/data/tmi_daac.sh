#!/bin/bash
#
# Purpose:
#	To FTP download TRMM data files from DAAC.
#
# EXAMPLE:
# 	$ tmi_daac.sh 1B11 2006 12
#
# History:
#	Khoa Doan

# Source function library.
. $CINT/bash/functions.sh

# Set shell options.
shopt -s nullglob

# Set script name.
declare -rx SCRIPT=${0##*/}

# Process command line parameters.
if [ $# -ne 3 ] ; then
    echo "Usage: $SCRIPT product year month" >&2
    exit -1
fi

# Check argument validity.
if [ $2 -lt 0 ] ; then
    echo "$SCRIPT:$LINENO: Invalid year value- $2" >&2
    exit -1
fi

# Check argument validity.
if [ $3 -gt 12 -o $3 -lt 1 ] ; then
    echo "$SCRIPT:$LINENO: Invalid month value- $3" >&2
    exit -1
fi

# Reassign command line arguments.
PROD=$1
YEAR=$2
MONTH=$3

# Figure out the days of the year for the starting day and ending day of
# the requested month, since TRMM data is organized in day-of-the-year
# directory at the source FTP site.. 
#     Get the last day of the year.
DEVE=`printf "12/31/%d" "$YEAR"`

#     Get the number of days in the year.
get_day_of_year $DEVE
NDAY=$__JDOY	# __JDOY is set in get_day_of_year function.

#     Get the first day of the month.
DBGN=`printf "%d/1/%d" "$MONTH" "$YEAR"`

#     Get the first day of the following month.
let "NMON=$MONTH+1"

#     Increment the year if the following month number is greater than 12.
let "YINC=0"
if [ $NMON -gt 12 ] ; then
    let "NMON=$NMON%12"
    let "YINC=$MONTH/12"
fi
let "NYR=$YEAR+$YINC"

#     Get the day of the year for the first day of the following month.
DEND=`printf "%d/1/%d" "$NMON" "$NYR"`

#     Get the day of the year for the starting day of the month.
get_day_of_year $DBGN
JBGN=$__JDOY

#     Get the day of the year for the ending day of the month.
get_day_of_year $DEND
JEND=$__JDOY
if [ $JEND -lt $JBGN ] ; then
    let "JEND=$JEND+$NDAY"
fi

# Set product level string.
DLVL="L${PROD:0:1}"

DISC="disc2"

for ((DOY=2; DOY<3; DOY++)) ; do
	# Set destination directory.
	DSTDIR=`printf '%s/TMI/%s/%s/%03d/' "$CINTDATA" "$PROD" "$YEAR" "$DOY"`
	printf "Destination Directory: %s\n" "$DSTDIR"

	# Create the destination directory if it doesn't exist.
	if [ ! -e $DSTDIR ] ; then
		/bin/mkdir -p $DSTDIR
	fi

	# Change to the destination directory.
	cd $DSTDIR

    # Set source.
    SRCDIR=`printf \
    'ftp://%s.nascom.nasa.gov/data/s4pa/TRMM_%s/TRMM_%s/%4d/%03d/%s*.HDF.Z' \
    "$DISC" "$DLVL" "$PROD" "$YEAR" "$DOY" "$PROD"`
	if [ "$PROD" = "1B11" ] ; then
		    SRCDIR=`printf \
		'ftp://%s.nascom.nasa.gov/data/s4pa/TRMM_%s/TRMM_%s/%4d/%03d/%s*.HDF' \
		"$DISC" "$DLVL" "$PROD" "$YEAR" "$DOY" "$PROD"`
	fi

    # Download the files of the day.
    printf "Downloading %s\n" "$SRCDIR"
    $NCFTP/ncftpget -V "$SRCDIR"

    # Compress the files.
    #for UNCMPRSD in $PROD*.HDF
    #do
	#	gzip -d $UNCMPRSD
    #done
	for COMPRSD in *.Z
    do
		FINDEX=`expr length $COMPRSD - 2` 
		FNAME=`expr substr $COMPRSD 1 $FINDEX`
		printf "Extracting %s to %s\n" $COMPRSD $FNAME
		gunzip -c $COMPRSD > $FNAME
    done
done

exit 0
