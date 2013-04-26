#!/bin/bash

# vb-modifyvm
#	Modify VM parameters

pdir=`dirname $0`
pname=`basename $0`

[ -n "$VBFUNCTIONS" ] || source $pdir/vbfunctions.sh

#
#	set the background title, unless already set by caller
#
: ${backtitle:="Virtual Box"}
backtitle="$backtitle - Modify VM Parameters"

vm=`pickavm`
[ $? = 0 ] || clearexit 0

while :
do
	param=`dialog --stdout --backtitle "$backtitle" --title "VM parameter for $vm" \
		--menu 'Select Parameter, or <Cancel> to return' 0 0 0 \
		mem	'Memory settings' \
		net	'Network settings' \
		vrde	'VRDE settings' `
	[ $? = 0 ] || break
	command="$pdir/vb-modifyvm-${param}.sh"
	[ -x "$command" ] && $command $vm
done

clearexit 0
