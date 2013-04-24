#!/bin/bash

# vb-createvm.sh
#	interactively create a VM.

pdir=`dirname $0`
pname=`basename $0`

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
	exec 3>&1
	formdata=`dialog --backtitle "$backtitle" --title "Create VM" \
		--form 'Note: I do not like whitespace in names!' 0 0 0 \
		name 1 1 "$VMName" 1 10 10 10 \
		ostype 2 1 "$OSType" 2 10 10 10 \
		2>&1 1>&3`
	retvalue=$?
	exec 3>&-
	[ "$retvalue" = 0 ] || break
	set -- $formdata
	vmname=$1
	ostype=$2
	command="$VBCREATE --name $vmname --ostype $ostype --register"
	dialog --backtitle "$backtitle" --title "Ready to create VM?" --aspect 20 \
		--yesno "About to run\n\n$command\n\nOK to proceed?" 0 0
	retvalue=$?
	if [ "$retvalue" = 0 ]
	then
		clear
		echo "$command" >&2
		echo >&2
		$command
		echo >&2
		read -p "PRESS ENTER TO CONTUNUE"
		echo >&2
		break
	fi
	# so the master said NO, back to the form with current data
	VMName="$vmname"
	OSType="$ostype"
done

clear
echo "$pname: Terminated!" >&2
