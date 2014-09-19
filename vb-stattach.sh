#!/bin/bash
#
# vb-stattach.sh
#	storage attachment sub-menu
#
# Copyright (c) 2013 Fred Youhanaie
#	http://www.gnu.org/licenses/gpl-2.0.html
#

pdir=$(dirname $0)
pname=$(basename $0)

[ -n "$VBFUNCTIONS" ] || source $pdir/vbfunctions.sh

#
# ctlattlist
#	get a list of attached devices for a given VM and controller
#
ctlattlist() {
	[ $# = 2 ] || return 1
	vm="$1"
	ctlname="$2"
	vb_showvminfo -m "$vm" |
	sed -ne "s/\"$ctlname-\([0-9][0-9]*-[0-9][0-9]*\)\"=\(\".*\"\)/\1 \2/p"
	return
}

#
# do_attach
#	attach a device to a storage controller
#
do_attach() {
	ctlname=$(getsctlname "$vm" $(pickasctl "$vm")) || return 1
	devlist=$(ctlattlist "$vm" "$ctlname") || return 1
	while :
	do
		portdev=$(vbdlg "$vm: $ctlname: Attach" \
			--cancel-label 'Cancel' \
			--menu "Select a device slot, or\n<Cancel> to return" 0 0 0 $devlist) || return 1
		port=$(echo $portdev | cut -d- -f1)
		dev=$(echo $portdev | cut -d- -f2)
		dtype=$( getselection "$vm: $ctlname: $portdev: Device Type?" \
			'dvddrive fdd hdd' hdd ) || return 1
		med=$( getselection "$vm: $ctlname: $portdevdev: Medium?" \
			'additions emptydrive filename none' filename ) || return 1
		if [ "$med" = filename ]
		then
			medium=$(getfilename 'Disk filename?' "$(getdeffolder)/") || return 1
		else
			medium="$med"
		fi
		runcommand "About to attach '$medium' to '$ctlname-$port-$dev' ($dtype) on '$vm'" \
			"vb_stattach '$vm' '$ctlname' '$port' '$dev' '$dtype' '$medium'" && break
	done
	return
}

#
# do_list
#	show a listing of the devices for current VM and a storage controller
#
do_list() {
	ctlname=$(getsctlname "$vm" $(pickasctl "$vm")) || return 1
	tmpfile=$(mktemp) &&
	ctlattlist "$vm" "$ctlname" >$tmpfile &&
	vbdlg "$vm: $ctlname: Current Attached devices" --textbox $tmpfile 0 0
	[ -f "$tmpfile" ] && rm "$tmpfile"
}

#
#	set the background title, unless already set by caller
#
: ${backtitle:="Virtual Box"}
backtitle="$backtitle - Storage"

vm=$(pickavm)
[ $? = 0 ] || clearexit 0

while :
do
	param=$(vbdlg "$vm: Storage Attachment" \
		--cancel-label 'Return' \
		--default-item list \
		--menu 'Select option, or\n<Return> for Main menu' 0 0 0 \
		attach	'Attach/remove a device'  \
		list	'List attached devices' )
	[ $? = 0 ] || break
	case "$param" in
	attach)	do_attach;;
	list)	do_list;;
	esac
done

clearexit 0
