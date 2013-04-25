#!/bin/bash

# vb-modifyvm-mem.sh
#	modify memory setting

pdir=`dirname $0`
pname=`basename $0`

[ -n "$VBFUNCTIONS" ] || source $pdir/vbfunctions.sh

#
#	set the background title, unless already set by caller
#
: ${backtitle:="Virtual Box - Modify VM"}
backtitle="$backtitle - Memory"

# we expect one arg, the VM name
[ $# != 1 ] && exit 1
VMName="$1"

VBMODIFY="VBoxManage modifyvm $VMName --memory"

VMmemory=`getvmpar $VMName memory`

while :
do
	formdata=`dialog --stdout --backtitle "$backtitle" --title "$VMName: memory setting" \
		--form 'Memory setting in MB, or <Cancel> to return' 0 0 0 \
		memory 1 1 "$VMmemory" 1 10 10 10 `
	[ $? = 0 ] || break
	set -- $formdata
	memory=$1
	runcommand "Ready to Modify VM?" "$VBMODIFY $memory"
	[ $? = 0 ] && break
	# so the master said NO, back to the form with current data
	VMMemory="$memory"
done

clear
echo "$pname: Terminated!" >&2
