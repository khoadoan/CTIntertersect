#!/bin/bash
#
# Purpose:
#	To get all CTInt TRMM data for a month.
#
# Example:
#	$ get_trmm.sh 2008 3
#
# History:
#	Khoa Doan	2012.07.20
#

# Set script name.
declare -rx SCRIPT=${0##*/}

# Code directory.
CODEDIR="$CINT/bash"

# Source functions.
. $CINT/bash/functions.sh

# Process command line.
if [ $# -ne 2 ] ; then
    echo "Usage $SCRIPT year month" >&2
    exit -1
fi

# Check year argument validity.
get_current_year
if [ $1 -lt 1998 -o $1 -gt $__YEAR ] ; then
    echo "$SCRIPT $LINENO: Invalid year value $1" >&2
    exit -1
fi

# Check month argument validity.
if [ $2 -lt 1 -o $2 -gt 12 ] ; then
    echo "$SCRIPT $LINENO: Invalid month value $2" >&2
    exit -1
fi

ERRDIR=$CODEDIR/output/tmi
if [ ! -e $ERRDIR ] ; then
    /bin/mkdir -p $ERRDIR
fi

# Run tmi_daac.sh on each product.
m=`printf '%02d' "$2"`
($CODEDIR/tmi_daac.sh 1B11 $1 $2 | tee $ERRDIR/$1${m}_1B11) \
	2> $ERRDIR/$1${m}_1B11.err
($CODEDIR/tmi_daac.sh 2A12 $1 $2 | tee $ERRDIR/$1${m}_2A12) \
	2> $ERRDIR/$1${m}_2A12.err
exit 0
