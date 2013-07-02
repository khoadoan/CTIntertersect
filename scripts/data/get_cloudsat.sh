#!/bin/bash
#
# Purpose:
#	To get all CTInt CloudSat data for a month.
#
# Example:
#	$ get_cloudsat.sh 2008 3
#
# History:
#	Khoa Doan	2012.07.20
#

# Set script name.
declare -rx SCRIPT=${0##*/}

# Code directory.
CODEDIR="$CINT/bash"

# Function path.
FUNCPATH="$CINT/bash/functions.sh"

# Source functions.
. $FUNCPATH

# Process command line.
if [ $# -ne 2 ] ; then
    echo "Usage $SCRIPT year month" >&2
    exit -1
fi

# Check year argument validity.
get_current_year
if [ $1 -lt 1998 -o $1 -gt ${__YEAR} ] ; then
    echo "$SCRIPT $LINENO: Invalid year value $1" >&2
    exit -1
fi

# Check month argument validity.
if [ $2 -lt 1 -o $2 -gt 12 ] ; then
    echo "$SCRIPT $LINENO: Invalid month value $2" >&2
    exit -1
fi

# Set Error Directory
ERRDIR=$CODEDIR/output/cloudsat
if [ ! -e $ERRDIR ] ; then
    /bin/mkdir -p $ERRDIR
fi

# Run trmm_daac.sh on each product.
m=`printf '%02d' "$2"`
($CODEDIR/cloudsat.sh 2B-GEOPROF R04 $1 $2 \
	| tee $ERRDIR/$1${m}_2B-GEOPROF) \
	2> $ERRDIR/$1${m}_2B-GEOPROF.err

exit 0
