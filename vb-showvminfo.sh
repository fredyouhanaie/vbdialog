#!/bin/bash

# vb-showvminfo
#	interactive showvminfo

pdir=`dirname $0`
pname=`basename $0`

#
#	set the background title, unless already set by caller
#
: ${backtitle:="Virtual Box"}
backtitle="$backtitle - Show VM Information"

VBSHOW='VBoxManage showvminfo '

while :
do
	VMLIST=`VBoxManage list vms | sed 's/["{}]//g'`
	vm=`dialog --stdout --backtitle "$backtitle" --title "List of known VMs" \
		--menu 'Select VM, or <Cancel> to return' 0 0 0 $VMLIST `
	[ $? = 0 ] || break
	tmpfile=`mktemp` &&
	$VBSHOW "$vm" >$tmpfile &&
	dialog --backtitle "$backtitle" --title "showvminfo $vm" --textbox $tmpfile 0 0 &&
	rm $tmpfile
done

clearexit 0
