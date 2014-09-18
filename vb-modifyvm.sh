#!/bin/bash
#
# vb-modifyvm.sh
#	Modify VM parameters
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
backtitle="$backtitle - Modify VM Parameters"

vm=$(pickavm)
[ $? = 0 ] || clearexit 0

while :
do
	param=$(vbdlg "VM parameter groups for $vm" \
		--cancel-label 'Return' \
		--menu '<OK> to modify selected group, or\n <Return> for Main menu' 0 0 0 \
		net	'Network settings' \
		system	'System settings' \
		vrde	'VRDE settings' \
		)
	[ $? = 0 ] || break
	command="$pdir/vb-modifyvm-${param}.sh"
	[ -x "$command" ] && $command $vm
done

clearexit 0
