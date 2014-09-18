#!/bin/bash
#
# vb-createvm.sh
#	interactively create a VM.
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
backtitle="$backtitle - Create VM"

VMName=''
OSType=Linux26

while :
do
	OSType=$(getostype $OSType)
	[ $? = 0 ] || break
	vmname=$(vbdlg "Create VM ($OSType)" \
		--cancel-label 'Cancel' \
		--form 'Type a name,\n<OK> to create VM,\n<Cancel> to return to main menu' 0 0 0 \
		name 1 1 "$VMName" 1 10 40 40 )
	[ $? = 0 ] || break
	runcommand "About to Create VM '$vmname' ($OSType)" \
		"vb_createvm '$vmname' $OSType"
	[ $? = 0 ] && break
	# so the master said NO, back to the form with current data
	VMName="$vmname"
done

clearexit 0
