#
# functions
#	This file contains functions used by most (or all) shell scripts in
#	the ../../bash directory.
#

declare __JDOY
declare -i __YEAR

strip_leading_zeros()
{
    while [ ${__JDOY:0:1} -eq 0 ] ; do
	__JDOY=${__JDOY#0}
    done
}

get_day_of_year()
{
    __JDOY=`date +%j -d $1`
    strip_leading_zeros
}

get_current_year()
{
    __YEAR=`date +%G`
}

