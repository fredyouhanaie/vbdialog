#!/bin/bash
#
# vb-modifyvm-system.sh
#	modify the System settings
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
: ${backtitle:="Virtual Box - Modify VM"}
backtitle="$backtitle - VRDE"

# we expect one arg, the VM name
[ $# != 1 ] && clearexit 1
VMName="$1"

VBMODIFY="vb_modifyvm '$VMName'"

while :
do
	VMmemory=$(getvmpar "$VMName" memory)
	VMpae=$(getvmpar "$VMName" pae)
	VMrtcuseutc=$(getvmpar "$VMName" rtcuseutc)

	choice=$(vbdlg "$VMName: System settings" \
		--cancel-label 'Return' \
		--menu '<OK> to modify parameter, or\n<Return> for Modify menu' 0 0 0 \
			'memory'	"$VMmemory" \
			'pae'		"$VMpae" \
			'rtcuseutc'	"$VMrtcuseutc" \
		)
	[ $? = 0 ] || break
	case "$choice" in
	memory)
		memory=$(getstring "$VMName setting for memory" "$VMmemory") &&
		runcommand "About to set memory for '$VMName' to $memory MB" "$VBMODIFY memory '$memory'"
		;;
	pae)
		pae=$(getselection "$VMName setting for pae" 'off on' "$VMpae") &&
		runcommand "About to set pae for '$VMName' to $pae" "$VBMODIFY pae '$pae'"
		;;
	rtcuseutc)
		rtcuseutc=$(getselection "$VMName setting for rtcuseutc" 'off on' "$VMrtcuseutc") &&
		runcommand "About to set rtcuseutc for '$VMName' to $rtcuseutc" "$VBMODIFY rtcuseutc '$rtcuseutc'"
		;;
	*)
		vbdlg "$VMName: System Settings" --msgbox "Unknown choice: $choice" 0 0
	esac
done

clearexit 0

