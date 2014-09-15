#!/bin/bash
#
# vb-modifyvm-vrde.sh
#	modify the VRDE setting
#
# Copyright (c) 2013 Fred Youhanaie
#	http://www.gnu.org/licenses/gpl-2.0.html
#

pdir=$(dirname $0)
pname=$(basename $0)

[ -n "$VBFUNCTIONS" ] || source $pdir/vbfunctions.sh

#
# vrde_list
#	list the current VRDE settings for a VM
#
vrde_list() {
	[ $# = 1 ] || return 1
	vm="$1"
	tmpfile=$(mktemp) &&
	vb_showvminfo -m "$vm" | grep '^vrde' >$tmpfile &&
	vbdlg "$vm: VRDE settings" --textbox "$tmpfile" 0 0
	[ -f "$tmpfile" ] && rm "$tmpfile"
}

#
#	set the background title, unless already set by caller
#
: ${backtitle:="Virtual Box - Modify VM"}
backtitle="$backtitle - VRDE"

# we expect one arg, the VM name
[ $# != 1 ] && clearexit 1
VMName="$1"

VBMODIFY="vb_modifyvm '$VMName'"

while :
do
	choice=$(vbdlg "$VMName: VRDE settings" \
		--default-item list \
		--menu 'Choose option, or <Cancel> to return' 0 0 0 \
			'disable'	'Enable VRDE' \
			'enable'	'Enable VRDE' \
			'list'		'List current settings' \
			'ports'		'Select ports' \
		)
	[ $? = 0 ] || clearexit 1
	case "$choice" in
	disable)
		runcommand 'Disabling VRDE' "$VBMODIFY vrde off"
		;;
	enable)
		runcommand 'Enabling VRDE' "$VBMODIFY vrde on"
		;;
	list)
		vrde_list "$VMName"
		;;
	ports)
		ports=$( getstring 'Setting for VRDE ports' $(getvmpar "$VMName" vrdeports) ) &&
		runcommand 'About to change the VRDE settings' "$VBMODIFY vrdeport '$ports'"
		;;
	esac
done

clearexit 0

