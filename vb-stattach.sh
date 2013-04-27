#!/bin/bash

# vb-stattach.sh
#	storage attachment sub-menu

pdir=`dirname $0`
pname=`basename $0`

[ -n "$VBFUNCTIONS" ] || source $pdir/vbfunctions.sh

#
# ctlattlist
#	get a list of attached devices for a given VM and controller
#
ctlattlist() {
	vm="$1"
	ctlname="$2"
	VBoxManage showvminfo "$vm" --machinereadable |
	sed -ne "s/\"$ctlname-\([0-9][0-9]*-[0-9][0-9]*\)\"=\(\".*\"\)/\1 \2/p"
	return
}

#
# do_attach
#	attach a device to a storage controller
#
do_attach() {
	ctlname=$(getsctlname "$vm" `pickasctl "$vm"`) || return 1
	devlist=$(ctlattlist "$vm" "$ctlname") || return 1
	while :
	do
		runcmd="VBoxManage storageattach $vm --storagectl $ctlname"
		portdev=$(dialog --stdout --backtitle "$backtitle" --title "$vm: $ctlname: Attach" \
			--menu "Select a device slot, or <Cancel> to return" 0 0 0 $devlist) || return 1
		port=$(echo $portdev | cut -d- -f1)
		dev=$(echo $portdev | cut -d- -f2)
		runcmd="$runcmd --port $port --device $dev"
		dtype=$( getselection "$vm: $ctlname: $portdev: Device Type?" \
			'dvddrive fdd hdd' hdd ) || return 1
		runcmd="$runcmd --type $dtype"
		med=$( getselection "$vm: $ctlname: $portdevdev: Medium?" \
			'additions emptydrive filename none' filename ) || return 1
		if [ "$med" = filename ]
		then
			medium=$(getfilename 'Disk filename?' "`getdeffolder`/") || return 1
		else
			medium="$med"
		fi
		runcmd="$runcmd --medium $medium"
		runcommand "Storage Attach" "$runcmd" && break
	done
	return
}

#
# do_list
#	show a listing of the devices for current VM and a storage controller
#
do_list() {
	ctlname=$(getsctlname "$vm" `pickasctl "$vm"`) || return 1
	tmpfile=`mktemp` &&
	ctlattlist "$vam" "$ctlname" >$tmpfile &&
	dialog --stdout --backtitle "$backtitle" \
		--title "$vm: $ctlname: Current Attached devices" \
		--textbox $tmpfile 0 0
	rm "$tmpfile"
}

#
#	set the background title, unless already set by caller
#
: ${backtitle:="Virtual Box"}
backtitle="$backtitle - Storage"

vm=`pickavm`
[ $? = 0 ] || clearexit 0

while :
do
	param=`dialog --stdout --backtitle "$backtitle" --title "$vm: Storage Attachment" \
		--default-item list \
		--menu 'Select option, or <Cancel> to return' 0 0 0 \
		attach	'Attach/remove a device'  \
		list	'List attached devices' `
	[ $? = 0 ] || break
	case "$param" in
	attach)	do_attach;;
	list)	do_list;;
	esac
done

clearexit 0
