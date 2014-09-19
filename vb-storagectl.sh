#!/bin/bash
#
# vb-storagectl.sh
#	storagectl functions
#
# Copyright (c) 2013 Fred Youhanaie
#	http://www.gnu.org/licenses/gpl-2.0.html
#

pdir=$(dirname $0)
pname=$(basename $0)

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
		param=$(vbdlg "$vm: Adding Storage Controller" \
			--extra-button --extra-label 'OK' --ok-label 'Change' \
			--cancel-label 'Cancel' \
			--menu '<Change> to set the parameters,\n<OK> to apply the change,or\n<Cancel> to return' 0 0 0 \
			Name	"$ctlName" \
			Type	"$ctlType" \
			Chip	"$ctlChip")
		retval=$?
		[ $retval = 3 ] && break
		[ $retval = 0 ] || return 1
		case $param in
		Name)
			ctlName=$(getstring 'Controller name' "$ctlName")
			;;
		Type)
			ctlType=$(getselection 'Controller Bus type' \
				'floppy ide sas sata scsi' "$ctlType")
			case $ctlType in
				floppy)	ctlChip='I82078';;
				ide)	ctlChip='PIIX4';;
				sas)	ctlChip='LSILogicSAS';;
				sata)	ctlChip='IntelAHCI';;
				scsi)	ctlChip='LSILogic';;
			esac
			;;
		Chip)
			case $ctlType in
				floppy)	ctlChipList='I82078';;
				ide)	ctlChipList='ICH6 PIIX3 PIIX4';;
				sas)	ctlChipList='LSILogicSAS';;
				sata)	ctlChipList='IntelAHCI';;
				scsi)	ctlChipList='BusLogic LSILogic';;
			esac
			ctlChip=$(getselection 'Controller Chipset type' "$ctlChipList" "$ctlChip")
			;;
		esac
	done
	runcommand "About to add storage controller '$ctlName', '$ctlType', '$ctlChip' to '$vm'" \
		"vb_addstctl '$vm' '$ctlName' '$ctlType' '$ctlChip'"
	return
}

#
# modify_ctl
#	let user modify selected setting of a controller
#
modify_ctl() {
	ctl=$(pickasctl "$vm") || return 1
	ctlName=$(getsctlname "$vm" "$ctl") || return 1
	ctlBoot=$(getvmpar $vm storagecontrollerbootable${ctl}) || return 1
	ctlChip=$(getvmpar $vm storagecontrollertype${ctl}) || return 1
	ctlPcount=$(getvmpar $vm storagecontrollerportcount${ctl}) || return 1
	while :
	do
		param=$(vbdlg "$vm: Modifying $ctlName" \
			--extra-button --extra-label 'OK' --ok-label 'Change' \
			--cancel-label 'Cancel' \
			--menu '<Change> to set the parameters,\n<OK> to apply the change,or\n<Cancel> to return' 0 0 0 \
			Boot	"$ctlBoot" \
			Chip	"$ctlChip" \
			Ports	"$ctlPcount" )
		retval=$?
		[ $retval = 3 ] && break
		[ $retval = 0 ] || return 1
		case $param in
		Boot)
			ctlBoot=$(getselection 'Controller Bootable state' 'on off' "$ctlBoot")
			;;
		Chip)
			ctlChip=$(getselection 'Controller Chipset type' \
				'BusLogic I82078 ICH6 IntelAHCI LSILogic LSILogicSAS PIIX3 PIIX4' \
				"$ctlType")
			;;
		Ports)
			ctlPcount=$(getstring 'Port Count' "$ctlPcount")
			;;
		esac
	done
	runcommand "Modifying Storage Controller '$ctlName' on '$vm', Boot=$ctlBoot, Chip=$ctlChip, Ports=$ctlPcount" \
		"vb_modstctl '$vm' '$ctlName' '$ctlBoot' '$ctlChip' '$ctlPcount'"
	return
}

#
# remove_ctl
#	let user pick and delete an existing controller
#
remove_ctl() {
	ctlName=$( getsctlname "$vm" $(pickasctl "$vm") )
	[ $? = 0 ] || return 1
	runcommand "About to remove storage Controller '$ctlName' on '$vm'" "vb_delstctl '$vm' '$ctlName'"
	return
}

#
# list_ctl
#	list the current controller and their settings
#
list_ctl() {
	tmpfile=$(mktemp)
	vb_showvminfo $vm | grep '^Storage Controller' >$tmpfile
	if [ -s "$tmpfile" ]
	then
		vbdlg "$vm: Storage Controller(s)" --textbox "$tmpfile" 0 0
	else
		vbdlg "$vm: Storage Controller(s)" --msgbox 'There are no Storage Controllers!' 0 0
	fi
        [ -f "$tmpfile" ] && rm "$tmpfile"
}

#
#	set the background title, unless already set by caller
#
: ${backtitle:="Virtual Box"}
backtitle="$backtitle - Storage Controller"

vm=$(pickavm)
[ $? = 0 ] || clearexit 1

while :
do
	cmd=$(vbdlg "$vm: Storage Controller" \
		--cancel-label 'Return' \
		--default-item list \
		--menu 'Select option, or\n<Return> for Main menu' 0 0 0 \
		add	'Add a Controller' \
		list	'List Storage Controllers' \
		modify	'Modify Controller parameters' \
		remove	'Remove a Controller')
	[ $? = 0 ] || break
	case "$cmd" in
		add)	add_ctl ;;
		list)	list_ctl ;;
		modify)	modify_ctl ;;
		remove)	remove_ctl
	esac
done

clearexit 0
