#!/bin/bash
#
# vb-createhd.sh
#	interactively create a hard disk
#
# Copyright (c) 2013 Fred Youhanaie
#	http://www.gnu.org/licenses/gpl-2.0.html
#

pdir=$(dirname $0)
pname=$(basename $0)

[ -n "$VBFUNCTIONS" ] || source $pdir/vbfunctions.sh

#
#	set the background title, unless already set by caller
#
: ${backtitle:="Virtual Box"}
backtitle="$backtitle - Create HD"

HDfolder=$(getdeffolder)

HDfile=''
HDsize=0
HDformat='VDI'

while :
do
	# Get the parameters
	while :
	do
		param=$(vbdlg 'Create HD' \
			--extra-button --extra-label 'OK' --ok-label 'Change' \
			--cancel-label 'Return' \
			--menu '<Change> parameter, or <Cancel> to return' 0 0 0 \
			File "$HDfile" Size "$HDsize MB" Format "$HDformat")
		retval=$?
		[ $retval = 3 ] && break
		[ $retval = 0 ] || clearexit 1
		case $param in
		File)	HDfile=$(getfilename 'HD filename' "${HDfolder}/")
			;;
		Size)	HDsize=$(getstring 'HD size in MB' "$HDsize")
			;;
		Format)	HDformat=$(getselection 'HD format' 'VDI VHD VMDK' "$HDformat")
			;;
		esac
	done
	runcommand "Ready to Create HD?" "vb_createhd '$HDfile' $HDsize $HDformat"
	[ $? = 0 ] && break
done

clearexit 0
