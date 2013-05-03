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

VBMODIFY="vbman modifyvm '$VMName'"

while :
do
	VMmemory=$(getvmpar "$VMName" memory)
	VMpae=$(getvmpar "$VMName" pae)
	VMrtcuseutc=$(getvmpar "$VMName" rtcuseutc)

	choice=$(vbdlg "$VMName: System settings" \
		--menu 'Choose parameter, or <Cancel> to return' 0 0 0 \
			'memory'	"$VMmemory" \
			'pae'		"$VMpae" \
			'rtcuseutc'	"$VMrtcuseutc" \
		)
	[ $? = 0 ] || break
	case "$choice" in
	memory)
		memory=$(getstring "$VMName setting for memory" "$VMmemory") &&
		runcommand 'About to change memory setting' "$VBMODIFY --memory '$memory'"
		;;
	pae)
		pae=$(getselection "$VMName setting for pae" 'off on' "$VMpae") &&
		runcommand 'About to change the pae setting' "$VBMODIFY --pae '$pae'"
		;;
	rtcuseutc)
		rtcuseutc=$(getselection "$VMName setting for rtcuseutc" 'off on' "$VMrtcuseutc") &&
		runcommand 'About to change rtcuseutc setting' "$VBMODIFY --rtcuseutc '$rtcuseutc'"
		;;
	*)
		vbdlg "$VMName: System Settings" --msgbox "Unknown choice: $choice" 0 0
	esac
done

clearexit 0

