#!/bin/bash

# vb-storagectl.sh
#	storagectl functions

pdir=`dirname $0`
pname=`basename $0`

[ -n "$VBFUNCTIONS" ] || source $pdir/vbfunctions.sh


#
# add_ctl
#	let user add a new controller to the current VM
#
add_ctl() {
	ctlName=IDEcontroller
	ctlType=ide
	ctlChip=PIIX4
	while :
	do
		param=`dialog --stdout --backtitle "$backtitle" --title "$vm: Adding Storage Controller" \
			--extra-button --extra-label 'OK' --ok-label 'Change' \
			--menu 'Set parameters, or <Cancel> to return' 0 0 0 \
			Name	"$ctlName" \
			Type	"$ctlType" \
			Chip	"$ctlChip"`
		retval=$?
		[ $retval = 3 ] && break
		[ $retval = 0 ] || return 1
		case $param in
		Name)
			ctlName=`getstring 'Controller name' "$ctlName"`
			;;
		Type)
			ctlType=`getselection 'Controller Bus type' \
				'floppy ide sas sata scsi' "$ctlType"`
			;;
		Chip)
			ctlChip=`getselection 'Controller Chipset type' \
				'BusLogic I82078 ICH6 IntelAHCI LSILogic LSILogicSAS PIIX3 PIIX4' \
				"$ctlType"`
			;;
		esac
	done
	runcommand "Ready to add Storage Controller?" \
		"VBoxManage storagectl $vm --name $ctlName --add $ctlType --controller $ctlChip"
	return
}

#
# modify_ctl
#	let user modify selected setting of a controller
#
modify_ctl() {
	ctl=`pickasctl "$vm"` || return 1
	ctlName=`getsctlname "$vm" "$ctl"` || return 1
	ctlBoot0=`getvmpar $vm storagecontrollerbootable${ctl}` || return 1
	ctlBoot=$ctlBoot0
	ctlChip0=`getvmpar $vm storagecontrollertype${ctl}` || return 1
	ctlChip=$ctlChip0
	ctlPcount0=`getvmpar $vm storagecontrollerportcount${ctl}` || return 1
	ctlPcount=$ctlPcount0
	while :
	do
		param=`dialog --stdout --backtitle "$backtitle" --title "$vm: Modifying $ctlName" \
			--extra-button --extra-label 'OK' --ok-label 'Change' \
			--menu 'Set parameters, or <Cancel> to return' 0 0 0 \
			Boot	"$ctlBoot" \
			Chip	"$ctlChip" \
			Ports	"$ctlPcount" `
		retval=$?
		[ $retval = 3 ] && break
		[ $retval = 0 ] || return 1
		case $param in
		Boot)
			ctlBoot=`getselection 'Controller Bootable state' 'on off' "$ctlBoot"`
			;;
		Chip)
			ctlChip=`getselection 'Controller Chipset type' \
				'BusLogic I82078 ICH6 IntelAHCI LSILogic LSILogicSAS PIIX3 PIIX4' \
				"$ctlType"`
			;;
		Ports)
			ctlPcount=`getstring 'Port Count' "$ctlPcount"`
			;;
		esac
	done
	# has anything changed?
	change=no
	runcmd="VBoxManage storagectl $vm --name $ctlName"
	if [ "$ctlBoot0" != "$ctlBoot" ]
	then
		runcmd="$runcmd --bootable $ctlBoot"
		change=yes
	fi
	if [ "$ctlChip0" != "$ctlChip" ]
	then
		runcmd="$runcmd --controller $ctlChip"
		change=yes
	fi
	if [ "$ctlPcount0" != "$ctlPcount" ]
	then
		runcmd="$runcmd --sataportcount $ctlPcount"
		change=yes
	fi
	[ "$change" = yes ] && runcommand 'Modifying Storage Controller' "$runcmd"
	return
}

#
# remove_ctl
#	let user pick and delete an existing controller
#
remove_ctl() {
	ctlName=$( getsctlname "$vm" `pickasctl "$vm"` )
	[ $? = 0 ] || return 1
	runcommand "Ready to remove storage Controller?" "VBoxManage storagectl $vm --name $ctlName --remove"
	return
}

#
# list_ctl
#	list the current controller and their settings
#
list_ctl() {
	dialogcmd="dialog --stdout --backtitle '$backtitle' --title '$vm: Storage Controller(s)'"
	tmpfile=`mktemp`
	VBoxManage showvminfo $vm | grep '^Storage Controller' >$tmpfile
	if [ -s "$tmpfile" ]
	then
		eval "$dialogcmd --textbox $tmpfile 0 0"
	else
		eval "$dialogcmd --msgbox 'There are no Storage Controllers!' 0 0"
	fi
        rm "$tmpfile"
}

#
#	set the background title, unless already set by caller
#
: ${backtitle:="Virtual Box"}
backtitle="$backtitle - Storage Controller"

vm=`pickavm`
[ $? = 0 ] || clearexit 1

while :
do
	cmd=`dialog --stdout --backtitle "$backtitle" --title "$vm: Storage Controller" \
		--default-item list \
		--menu 'Select option, or <Cancel> to return' 0 0 0 \
		add	'Add a Controller' \
		list	'List Storage Controllers' \
		modify	'Modify Controller parameters' \
		remove	'Remove a Controller'`
	[ $? = 0 ] || break
	case "$cmd" in
		add)	add_ctl ;;
		list)	list_ctl ;;
		modify)	modify_ctl ;;
		remove)	remove_ctl
	esac
done

clearexit 0
