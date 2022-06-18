#!/bin/bash 

usage()
{
echo "Usage: linShot [option] filename
linShot finds changes in filesystem after an executable runs
to help determine what it might've altered.
Options:
  -h, --help                          show usage (this page)
  -d, --directory=/DIRECTORY/PATH     directory to search
                                      (default: current working directory)
  -t, --timeout=30                    time before executable timeout (s)
                                      (default: 10)
Examples:
	linShot malware.sh
	linShot -t 15 malware
	linShot -d /home /root/malware.o
	linShot --directory=/usr/bin --timeout=15 malware"
}

# Arrays for results
found=()
new=()
modified=()
perms=()

# Argument variables
BPATH=$(pwd)  # base path (where to start searching)
EXE=unset   # executable to be run
TO=10 # timeout time

# Parse arguments
PARSED_ARGS=$(getopt -a -n linShot -o h,d:,t: --long help,directory:,timeout: -- "$@")
VALID_ARGS=$?

# Catch invalid arguments
if [[ ("$VALID_ARGS" != "0") ]]; then
	echo "Try 'linShot --help' for more information"
	exit 2
fi

eval set -- "$PARSED_ARGS"

while :
do
	case "$1" in
		-h | --help)
		usage
		exit
		;;

		-d | --directory)		
		BPATH=$2
		shift 2
		;;

		-t | --timeout)
		TO=$2
		shift 2
		;;

		--)
		if [[ -z $2 ]]; then
			echo  -e "linShot: missing filename\nTry 'linShot --help' for more information"
			exit 2
		else
			EXE=$(realpath $2)
		fi
		break
		;;
	esac
done

# Sort files into their respective place
find_place(){

	atime=$(stat $1 | grep "Access: 2" | awk '{print $3}')
	mtime=$(stat $1 | grep "Modify:" | awk '{print $3}')
	ctime=$(stat $1 | grep "Change:" | awk '{print $3}')

	if [[ $atime == $ctime && $atime == $mtime ]]; then
		new+=( $1 )

	elif [[ $ctime == $mtime && $ctime != $atime ]]; then
		modified+=( $1 )

	elif [[ $ctime != $mtime ]]; then
		perms+=( $1 )

	else
		echo "idklol"
	fi
}

#########     
# start #    
#########     

touch ./tmptime # tmp file to compare times to

timeout $TO $EXE # timeout, in case the file hangs

# find all files that have had their access, modify, or permissions
# changed since the executable was run. append to list
found+=$(find $BPATH -type f \( -anewer ./tmptime -o -newer ./tmptime -o -cnewer ./tmptime \))

for path in ${found[@]};
do
	find_place $path # sort found filepaths
done

# Clean
rm ./tmptime

# Output
printf "~~~~~linShot Results~~~~~\n\nExecutable: %s\nSearching: %s\n\n" "$EXE" "$BPATH"
printf "New Files:\n"
printf "\t%s\n" "${new[@]}"
printf "\nModified (and/or new) Files:\n"
printf "\t%s\n" "${modified[@]}"
printf "\nPermissions changed:\n"
printf "\t%s\n" "${perms[@]}"
