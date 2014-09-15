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
	formdata=$(vbdlg 'Create VM' \
		--cancel-label 'Return' \
		--form 'Note: I do not like whitespace in names!' 0 0 0 \
		name 1 1 "$VMName" 1 10 40 40 \
		ostype 2 1 "$OSType" 2 10 40 40 )
	[ $? = 0 ] || break
	set -- $formdata
	vmname=$1
	ostype=$2
	runcommand "Ready to Create VM?" "vb_createvm '$vmname' $ostype"
	[ $? = 0 ] && break
	# so the master said NO, back to the form with current data
	VMName="$vmname"
	OSType="$ostype"
done

clearexit 0
