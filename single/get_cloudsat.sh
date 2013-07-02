#!/bin/bash
#
# Purpose:
#	To FTP download CloudSat data files from CloudSat Data Processing
#	Center.
#
# EXAMPLE:
# 	$ cloudsat.sh 2B-GEOPROF R04 2006 12
#
# Author:	K.-S. Kuo

# Source function library.
. $HOME/CTInt/Code/Operation/libsrc/bash/functions.sh

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
PROD=$1
RELEASE=$2
YEAR=$3
MONTH=$4

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

# Set destination directory.
DSTDIR=`printf \
	'/discover/nobackup/kkuo/CTInt/Input/CloudSat/%s/%02d/%s' \
	"$YEAR" "$MONTH" "$RELEASE"`
printf "Destination Directory: %s\n" "$DSTDIR"

# Create the destination directory if it doesn't exist.
if [ ! -e $DSTDIR ] ; then
    /bin/mkdir -p $DSTDIR
fi

# Change to the destination directory.
cd $DSTDIR

for ((DOY=$JBGN; DOY<$JEND; DOY++)) ; do

    # Set source.
    SRCDIR=`printf \
    'ftp://ftp1.cloudsat.cira.colostate.edu/%s.%s/%4d/%03d/*%s*.hdf.zip' \
    "$PROD" "$RELEASE" "$YEAR" "$DOY" "$PROD"`

    # Download the files of the day.
    printf "Downloading %s\n" "$SRCDIR"
    /usr/bin/ncftpget -u trmm -p tm332vi -V "$SRCDIR"

done

exit 0
