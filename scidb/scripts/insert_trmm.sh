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
		HDFFNAME=`expr substr $COMPRSD 1 $FINDEX`
		printf "Extracting %s to %s\n" $COMPRSD $HDFFNAME
		gunzip -c $COMPRSD > $HDFFNAME
	
		# Convert hdf files to csv
		"$CONVERT_SCRIPT_DIR/run_trmm.sh" "$MATLAB_MCR_DIR"
		
		FINDEX=`expr length $HDFFNAME - 4` 
		FNAME=`expr substr $COMPRSD 1 $FINDEX`
		
		CSVFILE=`printf "%s/%s.csv" "$WORKING_DIR_CSV" "$FNAME"`
		SCIDBFILE=`printf "%s/%s.scidb" "$WORKING_DIR_SCIDB" "$FNAME"`
		
		# Convert CSV files to Scidb
		echo "...Processing $CSVFILE to $SCIDBFILE"
		/opt/scidb/13.3/bin/csv2scidb -s 1 -p NNNNNN < $CSVFILE > $SCIDBFILE
		echo "...Load to Temp"
		/opt/scidb/13.3/bin/iquery -naq "load(trmm_1c21_t, '$SCIDBFILE');"
		echo "...Redimension"
		/opt/scidb/13.3/bin/iquery -naq "redimension_store(trmm_1c21_t,trmm_1c21_i);"
		echo "...Load to Target"
		/opt/scidb/13.3/bin/iquery -naq "insert(trmm_1c21_i, trmm_1c21);"
	
		#Remove temporary files
		echo "Remove $COMPRSD, $HDFFNAME, $CSVFILE, $SCIDBFILE"
		/bin/rm -f "$COMPRSD"
		/bin/rm -f "$HDFFNAME"
		/bin/rm -f "$CSVFILE"
		/bin/rm -f "$SCIDBFILE"
    done

    
done