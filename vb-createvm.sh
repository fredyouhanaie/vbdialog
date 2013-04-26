#!/bin/bash

# vb-createvm.sh
#	interactively create a VM.

pdir=`dirname $0`
pname=`basename $0`

[ -n "$VBFUNCTIONS" ] || source $pdir/vbfunctions.sh

#
#	set the background title, unless already set by caller
#
: ${backtitle:="Virtual Box"}
backtitle="$backtitle - Create VM"

VBCREATE='VBoxManage createvm'

VMName=''
OSType=Linux26

while :
do
	OSType=`getostype $OSType`
	[ $? = 0 ] || break
	formdata=`dialog --stdout --backtitle "$backtitle" --title "Create VM" \
		--form 'Note: I do not like whitespace in names!' 0 0 0 \
		name 1 1 "$VMName" 1 10 10 10 \
		ostype 2 1 "$OSType" 2 10 10 10 `
	[ $? = 0 ] || break
	set -- $formdata
	vmname=$1
	ostype=$2
	runcommand "Ready to Create VM?" "$VBCREATE --name $vmname --ostype $ostype --register"
	[ $? = 0 ] && break
	# so the master said NO, back to the form with current data
	VMName="$vmname"
	OSType="$ostype"
done

clearexit 0
