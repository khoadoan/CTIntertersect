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
CODEDIR="$CINT/scripts/data"

# Source functions.
. $CODEDIR/functions.sh

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

ERRDIR=$CODEDIR/output/trmm
if [ ! -e $ERRDIR ] ; then
    /bin/mkdir -p $ERRDIR
fi

# Run trmm_daac.sh on each product.
m=`printf '%02d' "$2"`
($CODEDIR/trmm_daac.sh 1C21 $1 $2 | tee $ERRDIR/$1${m}_1C21) \
	2> $ERRDIR/$1${m}_1C21.err
#($CODEDIR/trmm_daac.sh 2A23 $1 $2 | tee $ERRDIR/$1${m}_2A23) \
#	2> $ERRDIR/$1${m}_2A23.err
#($CODEDIR/trmm_daac.sh 2A25 $1 $2 | tee $ERRDIR/$1${m}_2A25) \
#	2> $ERRDIR/$1${m}_2A25.err

exit 0
