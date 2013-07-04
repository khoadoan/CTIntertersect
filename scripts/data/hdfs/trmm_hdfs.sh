#!/bin/bash
#
# Purpose:
#	To FTP download TRMM data files from DAAC.
#
# EXAMPLE:
# 	$ trmm_daac.sh 1C21 2006 12
#
# History:
#	Khoa Doan

CODEDIR="$CINT/scripts/data"
CINTDATA="/user/kdoan1/CInt/data"
# Source function library.
. $CODEDIR/functions.sh

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
TMP=`pwd`

echo "Intermediate directory is $TMP"

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
if [ "$PROD" = "1C21" -o "$PROD" = "1B01" ] ; then
    DISC="disc3"
fi

for ((DOY=$JBGN; DOY<$JEND; DOY++)) ; do
        # Set destination directory.
	DSTDIR=`printf '%s/TRMM/%s/%s/%03d/' "$CINTDATA" "$PROD" "$YEAR" "$DOY"`
	printf "Destination Directory: %s\n" "$DSTDIR"

	# Create the destination directory if it doesn't exist.
	# if [ `hadoop fs -test -d "$DSTDIR"` -eq -1 ]; then
	   hadoop fs -mkdir -p "$DSTDIR"
	   echo "Creating  directory $DSTDIR in HDFS"
	# fi
	
	# Create TMP Directory to store HDFS File
	TMP_DIR=`printf "%s/%s/%s/%03d/" "$TMP" "$PROD" "$YEAR" "$DOY"`
	if [ ! -e $TMP_DIR ] ; then
		/bin/mkdir -p "$TMP_DIR"
	fi
	cd $TMP_DIR
	
	# Set source.
    SRCHOST="198.118.195.88"
    SRCDIR=`printf \
    'data/s4pa/TRMM_%s/TRMM_%s/%4d/%03d' \
    "$DLVL" "$PROD" "$YEAR" "$DOY"`

    # Download the files of the day.
    printf "Connecting to %s at %s\n" "$SRCDIR" "$SRCHOST"
    /usr/local/bin/python "$CODEDIR/ftpget.py" "$SRCHOST" "$SRCDIR" "$TMP_DIR" "HDF.Z"
	
	# UnCompress the files if any
	for COMPRSD in *.Z
    do
		FINDEX=`expr length $COMPRSD - 2` 
		FNAME=`expr substr $COMPRSD 1 $FINDEX`
		printf "Extracting %s to %s\n" $COMPRSD $FNAME
		gunzip -c $COMPRSD > $FNAME
    done
	
	# Put to HDFS
	hadoop fs -put *.HDF "$DSTDIR"
	
	# Delete temp dir
	/bin/rm -r -f $TMP_DIR
done

exit 0
