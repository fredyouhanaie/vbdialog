#!/bin/bash

# vb-modifyvm-net.sh
#	modify NIC settings

pdir=`dirname $0`
pname=`basename $0`

[ -n "$VBFUNCTIONS" ] || source $pdir/vbfunctions.sh

#
#	set the background title, unless already set by caller
#
: ${backtitle:="Virtual Box - Modify VM"}
backtitle="$backtitle - Network"

# we expect one arg, the VM name
[ $# != 1 ] && clearexit 1
VMName="$1"

VBMODIFY="VBoxManage modifyvm $VMName "

while :
do
	# pick a nic between 1 and 8
	NIClist=$( for n in {1..8}; do echo "$n `getvmpar $VMName nic$n`"; done )
	nic=`dialog --stdout --backtitle "$backtitle" --title "$VMName: NIC selection" \
		--default-item 1 \
		--menu 'Select a NIC, or <Cancel> to return' 0 0 0 \
		$NIClist`
	[ $? = 0 ] || break

	while :
	do
		### get the NIC params
		nicparams=$(getnicparams $VMName $nic)
		nicpar=`dialog --stdout --backtitle "$backtitle" --title "$VMName: NIC${nic} settings" \
			--menu 'Select param, or <Cancel> to return' 0 0 0 $nicparams`
		[ $? = 0 ] || break
		# get the par value
		case "$nicpar" in
		nic?)
			newvalue=`modifynicmenu $VMName $nicpar "bridged generic hostonly intnet nat none null"`
			retval=$?
			;;
		nictype?)
			newvalue=`modifynicmenu $VMName $nicpar "2540EM 82543GC 82545EM Am79C970A Am79C973 virtio"`
			retval=$?
			;;
		*)	retval=1
		esac
		[ "$retval" = 0 ] || break
		runcommand "Ready to Modify VM?" "$VBMODIFY --$nicpar $newvalue"
		[ $? = 0 ] && break
		# the command did not run, let's start again
	done
done

clearexit 0
