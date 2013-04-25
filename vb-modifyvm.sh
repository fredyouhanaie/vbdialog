#!/bin/bash

# vb-modifyvm
#	Modify VM parameters

pdir=`dirname $0`
pname=`basename $0`

[ -n "$VBFUNCTIONS" ] && source $pdir/vbfunctions.sh

#
#	set the background title, unless already set by caller
#
: ${backtitle:="Virtual Box"}
backtitle="$backtitle - Modify VM Parameters"

while :
do
	VMLIST=`VBoxManage list vms | sed 's/["{}]//g'`
	exec 3>&1
	vm=`dialog --backtitle "$backtitle" --title "List of known VMs" \
		--menu 'Select a VM to modify, or <Cancel> to return' 0 0 0 $VMLIST 2>&1 1>&3`
	retval=$?
	exec 3>&-
	[ "$retval" = 0 ] || break
	exec 3>&1
	param=`dialog --backtitle "$backtitle" --title "VM parameter for $vm" \
		--menu 'Select Parameter, or <Cancel> to return' 0 0 0 \
		mem	'Memory settings' \
		net	'Network settings' \
		vrde	'VRDE settings' \
		2>&1 1>&3`
	retval=$?
	exec 3>&-
	if [ "$retval" = 0 ]
	then
		command="$pdir/vb-modifyvm-${param}.sh"
		[ -x "$command" ] && $command $vm
	fi
done

clear
echo "$pname: Terminated!" >&2
