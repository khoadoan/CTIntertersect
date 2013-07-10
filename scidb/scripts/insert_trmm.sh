#!/bin/bash

# Read in the argument
PROD=$1
YEAR=$2
MONTH=$3
WORKING_DIR=$4
CONVERT_SCRIPT_DIR=$5
MATLAB_MCR_DIR=$6
CINTDATA="/user/kdoan1/CInt/data"

# Intialization

WORKING_DIR_HDF="$WORKING_DIR/hdf"
WORKING_DIR_CSV="$WORKING_DIR/csv"
WORKING_DIR_SCIDB="$WORKING_DIR/scidb"

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
	HDFSFILES=`printf '%s/TRMM/%s/%s/%03d/*.HDF.Z' "$CINTDATA" "$PROD" "$YEAR" "$DOY"`
    
	# download hdf files from HDFS
	cd "$WORKING_DIR_HDF"
    hadoop fs -get "$HDFSFILES"
	
	# uncompress
	for COMPRSD in *.HDF.Z
    do
		FINDEX=`expr length $COMPRSD - 2` 
		FNAME=`expr substr $COMPRSD 1 $FINDEX`
		printf "Extracting %s to %s\n" $COMPRSD $FNAME
		gunzip -c $COMPRSD > $FNAME
    done

    # Convert hdf files to csv
	"$CONVERT_SCRIPT_DIR/run_cloudsat.sh" "$MATLAB_MCR_DIR"
    
	# Convert CSV files to Scidb
	for f in "$WORKING_DIR_CSV/*.csv"
	do
		bf=`basename $f`
		nf=`printf "%s/%s.scidb" "$WORKING_DIR_SCIDB" "$bf"`
		echo "...Processing $bf to $nf"
		/opt/scidb/13.3/bin/csv2scidb -s 1 -p NNNNNN < $bf > $nf
		echo "...Load to Temp"
		/opt/scidb/13.3/bin/iquery -aq "load(trmmt, '$nf');"
		echo "...Redimension"
		/opt/scidb/13.3/bin/iquery -aq "redimension_store(trmmt,trmm1);"
		echo "...Load to Target"
		/opt/scidb/13.3/bin/iquery -aq "insert(trmm1, trmm);"
	done
	
	#Remove temporary files
	/bin/rm -r -f "$WORKING_DIR_HDF/*"
	/bin/rm -r -f "$WORKING_DIR_CSV/*"
	/bin/rm -r -f "$WORKING_DIR_SCIDB/*"
done