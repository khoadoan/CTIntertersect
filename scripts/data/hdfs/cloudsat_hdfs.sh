#!/bin/bash
#
# Purpose:
#	To FTP download CloudSat data files from CloudSat Data Processing
#	Center.
#
# EXAMPLE:
# 	$ cloudsat.sh 2B-GEOPROF R04 2006 12
#
# Author:	Khoa Doan

CODEDIR="$CINT/scripts/data"
CINTDATA="/user/kdoan1/CInt/data"
# Source function library.
. $CODEDIR/functions.sh

# Set shell options.
shopt -s nullglob

# Set script name.
declare -rx SCRIPT=${0##*/}

# Process command line parameters.
if [ $# -ne 4 ] ; then
    echo "Usage: $SCRIPT product release year month" >&2
    exit -1
fi

# Check argument validity: release number.
#if [ $2 -ne "R03" -o $2 -ne "R04" ] ; then
    #echo "$SCRIPT $LINENO: Invalid release number- $2" >&2
    #exit -1
#fi

# Check argument validity: year.
if [ $3 -lt 0 ] ; then
    echo "$SCRIPT:$LINENO: Invalid year value- $3" >&2
    exit -1
fi

# Check argument validity: month.
if [ $4 -gt 12 -o $3 -lt 1 ] ; then
    echo "$SCRIPT:$LINENO: Invalid month value- $4" >&2
    exit -1
fi

# Reassign command line arguments.
PROD=$1 #2B-GEOPROF
RELEASE=$2
YEAR=$3
MONTH=$4
CWD=`pwd`
TMP=`printf "%s/tmp" $CWD`

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
YINC=0
if [ $NMON -gt 12 ] ; then
    let "NMON=$NMON%12"
    let "YINC=$NMON/12"
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

for ((DOY=$JBGN; DOY<$JEND; DOY++)) ; do
# Set destination directory.
	DSTDIR=`printf \
		'%s/CloudSat/%s/%03d/%s' \
		"$CINTDATA" "$YEAR" "$DOY" "$RELEASE"`
	
	# Reset to Home Directory: This is used to prevent hadoop mkdir error
	cd "~"
	printf "%d: Destination Directory: %s\n" "$DOY" "$DSTDIR"
	
	echo "Creating  directory $DSTDIR in HDFS"
	hadoop fs -mkdir "$DSTDIR"
    
	# Create TMP Directory to store HDFS File
	TMP_DIR=`printf "%s/%s-%s-%03d/" "$TMP" "$YEAR" "$DOY" "$RELEASE"`
	if [ ! -e $TMP_DIR ] ; then
		/bin/mkdir -p "$TMP_DIR"
	fi
	cd $TMP_DIR
	
    # Set source.
	SRCHOST="129.82.109.195"
    SRCDIR=`printf \
    '%s.%s/%4d/%03d' \
    "$PROD" "$RELEASE" "$YEAR" "$DOY"`
	
	# Download the files of the day.
    printf "Connecting to %s at %s\n" "$SRCDIR" "$SRCHOST"
    /usr/local/bin/python "$CODEDIR/ftpget.py" "$SRCHOST" "$SRCDIR" "$TMP_DIR" "HDF.ZIP" "trmm" "tm332vi"
	
	# Put to HDFS
	echo "Uploading to HDFS at $DSTDIR"
	hadoop fs -put *.ZIP "$DSTDIR"
	
	# Delete temp dir
	echo "Remote local files"
	/bin/rm -r -f $TMP_DIR
done

exit 0
