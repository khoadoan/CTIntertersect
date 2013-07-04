#!/bin/bash


# Read in the argument
PROD=$1
YEAR=$2
MONTH=$3

# Intialization

WORKING_DIR_HDF="/gpfsm/dnb32/kdoan1/CINT/data/working/hdf"
WORKING_DIR_CSV="/gpfsm/dnb32/kdoan1/CINT/data/working/csv"
WORKING_DIR_SCIDB="/gpfsm/dnb32/kdoan1/CINT/data/working/scidb"

if [ ! -e $WORKING_DIR_HDF ] ; then
    /bin/mkdir -p $WORKING_DIR_HDF
fi

if [ ! -e $WORKING_DIR_CSV ] ; then
    /bin/mkdir -p $WORKING_DIR_CSV
fi

if [ ! -e $WORKING_DIR_SCIDB ] ; then
    /bin/mkdir -p $WORKING_DIR_SCIDB
fi

# Figure out the days of the year for the starting day and ending day of
# the requested month, since TRMM data is organized in day-of-the-year
# directory at the source FTP site.. 
#     Get the last day of the year.
DEVE=`printf "12/31/%d" "$YEAR"`

#     Get the number of days in the year.
get_day_of_year $DEVE
NDAY=$__JDOY# __JDOY is set in get_day_of_year function.

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

for ((DOY=$JBGN; DOY<$JEND; DOY++)); do
    # Copy HDF files to Working directory
    # TODO: to uncompress Z files into TEMP
    HDFFILES=`printf \
      '/discover/nobackup/kdoan1/CINT/data/TRMM/%s/%4d/%03d/*.hdf' \
      "$PROD" "$YEAR" "$DOY"`
    /bin/cp "$HDFFILES" "$WORKING_DIR_HDF"
    
    # Convert HDF files to CSV
    

done





# Convert CSV files to Scidb

# Insert into 1-D array

# Redimension into intermediate array

# Update Target Array
