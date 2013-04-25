#!/bin/bash

# vb-deletevm
#	Delete VM

pdir=`dirname $0`
pname=`basename $0`

[ -n "$VBFUNCTIONS" ] || source $pdir/vbfunctions.sh

#
#	set the background title, unless already set by caller
#
: ${backtitle:="Virtual Box"}
backtitle="$backtitle - Delete VM"

VBDELETE='VBoxManage unregistervm --delete'

while :
do
	VMLIST=`VBoxManage list vms | sed 's/["{}]//g'`
	vm=`dialog --stdout --backtitle "$backtitle" --title "List of current VMs" \
		--menu 'Select a VM to delete, or <Cancel> to return' 0 0 0 $VMLIST `
	[ $? = 0 ] || break
	runcommand "Ready to Delete VM?" "$VBDELETE $vm"
	[ $? = 0 ] && break
done

clearexit 0
