#!/bin/bash

# vb-modifyvm-vrde.sh
#	modify the VRDE setting

pdir=`dirname $0`
pname=`basename $0`

[ -n "$VBFUNCTIONS" ] || source $pdir/vbfunctions.sh

#
#	set the background title, unless already set by caller
#
: ${backtitle:="Virtual Box - Modify VM"}
backtitle="$backtitle - VRDE"

# we expect one arg, the VM name
[ $# != 1 ] && exit 1
VMName="$1"

VBMODIFY="VBoxManage modifyvm $VMName --vrde"

VMvrde=`getvmpar $VMName vrde`

while :
do
	exec 3>&1
	formdata=`dialog --backtitle "$backtitle" --title "$VMName: VRDE setting" \
		--form 'Enter on/off, or <Cancel> to return' 0 0 0 \
		vrde 1 1 "$VMvrde" 1 10 10 10 \
		2>&1 1>&3`
	retvalue=$?
	exec 3>&-
	[ "$retvalue" = 0 ] || break
	set -- $formdata
	vrde=$1
	runcommand "Ready to Modify VM?" "$VBMODIFY $vrde"
	retval=$?
	[ "$retval" = 0 ] && break
	# so the master said NO, back to the form with current data
	VMvrde="$vrde"
done

clear
echo "$pname: Terminated!" >&2
