#!/bin/bash
#
# vbfunctions.sh
#	common shell functions
#
# Copyright (c) 2013 Fred Youhanaie
#	http://www.gnu.org/licenses/gpl-2.0.html
#

pdir=$(dirname $0)

export VBFUNCTIONS=1

[ -n "$VBMANFUNCTIONS" ] || source $pdir/vbmanfunctions.sh

#
# vbdlg
#	A wrapper for the standard dialog command.
#	This allows standard appearance for all the widgets, as well as
#	allowing for a central point for logging and debugging.
#	$1		is expected to be the widget title.
#	$backtitle	this will be set/overriden with the scripts.
#
vbdlg() {
	[ $# -gt 2 ] || return 1
	title="$1"
	shift
	dialog --stdout --backtitle "$backtitle" --title "$title" "$@"
}
export -f vbdlg

#
# getvmpar
#	Given a vm and parameter name, return its current value.
#	Strip away the double-quotes at the beginning and end, if any.
#
getvmpar() {
	[ $# = 2 ] || return 1
	vm="$1"
	par="$2"
	vb_showvminfo -m "$vm" | sed -ne "s/$par=\(.*\)$/\1/p" | sed -e 's/^"//' -e 's/"$//'
}
export -f getvmpar

#
# runcommand
#	display command, get confirmation, then run if OK.
#
runcommand() {
	[ $# = 2 ] || return 1
	title=$1
	command=$2
	vbdlg "Confirm changes to VirtualBox" --aspect 20 --yesno "$title\n\nOK to proceed?" 0 0
	[ "$?" = 0 ] || return 1
	clear
	echo "$command" >&2
	echo >&2
	eval "$command"
	res=$?
	echo >&2
	read -p "[result=$res]	PRESS ENTER TO CONTINUE"
	echo >&2
	return 0
}
export -f runcommand

#
# getoslist
#	generate a list of OS type IDs and quoted descriptions
#
getoslist() {
	vb_list ostypes | egrep '^ID:|^Description:' | sed -e 's/^.*:  *//' |
	while read name
	do
		read desc
		echo "$name '$desc' "
	done | sort | tr '\n' ' '
}
export -f getoslist

#
# getostype
#	Let the user choose an OS type from a menu
#
getostype() {
	defaultos=$1
	: ${defaultos:=Linux26}
	eval "vbdlg 'Current OS Types' --default-item '$defaultos' \
		--menu 'Select OS type, or <Cancel> to return' 0 0 0 \
		$(getoslist)"
	return $?
}
export -f getostype

#
# clearexit
#	clear the screen and exit
#
clearexit() {
	clear
	echo "$pname: Terminated!" >&2
	exit $1
}
export -f clearexit

#
# getnicparams
#	get a list of param/values pairs for a given VM/NIC
#
getnicparams() {
	[ $# = 2 ] || return 1
	vm=$1
	nic=$2
	state=$(getvmpar $vm nic${nic})
	[ -n "$state" ] || return
	echo "nic${nic} \"$state\""
	[ "$state" = "none" ] && return
	vb_showvminfo -m $vm | egrep "^nic[^=]+${nic}=" | awk -F= '{print $1 " " $2}'
}
export -f getnicparams

#
# modifynicmenu
#	given a VM and NIC parameter, and list of allowed values
#	let the user choose new value.
#	The 3rd parameter is a blank separated list of allowed values.
#	the allowed values for a given parameter can be obtain by running
#	'VBoxManage modifyvm'
#
modifynicmenu() {
	[ $# = 3 ] || return 1
	vm="$1"
	nicpar="$2"
	valuelist="$3"
	menulist=$( for v in $valuelist; do echo "$v $v"; done)
	value=$(getvmpar $vm $nicpar)
	[ $? = 0 ] || return 1
	vbdlg "$vm: $nicpar" \
		--default-item $value --menu 'Select new value, or <Cancel> to return' 0 0 0 \
		$menulist
	return
}
export -f modifynicmenu

#
# modifynicinput
modifynic() {
	[ $# = 2 ] || return 1
	vm="$1"
	nicpar="$2"
	value=$(getvmpar $vm $nicpar)
	[ $? = 0 ] || return 1
	vbdlg "$vm $nicpar" \
		--form 'Enter a new value, or <Cancel> to return' 0 0 0 \
		"$nicpar" 1 1 "$value" 1 10 10 10
	return
}
export -f modifynic

#
# pickavm
#	let the user pick a vm from the list
#
# TODO: check for empty vm list
pickavm() {
	VMLIST=$(vb_list vms | sed 's/["{}]//g' | sort)
	vbdlg 'List of current VMs' \
		--menu 'Select a VM, or <Cancel> to return' 0 0 0 $VMLIST
	return
}
export -f pickavm

#
# getfilename
#	let user pick a directory/file
#	$1	title
#	$2	initial path
#
getfilename() {
	[ $# = 2 ] || return 1
	vbdlg "$1" --fselect "$2" 0 0
	return
}
export -f getfilename

#
# getstring
#	ask user for a name/number
#	$1	title
#	$2	default value
#
getstring() {
	[ $# = 2 ] || return 1
	vbdlg "$1" \
		--inputbox 'Enter value, or <Cancel> to return' 0 0 "$2"
	return
}
export -f getstring

#
# getselection
#	let user pick an option from a selection
#	$1	title
#	$2	allowed values
#	$3	default selection
#
getselection() {
	[ $# = 3 ] || return 1
	title="$1"
	vlist="$2"
	default="$3"
	menulist=$( for v in $vlist; do echo -n "$v $v "; done)
	vbdlg "$title" \
		--default-item "$default" --menu 'Select new value, or <Cancel> to return' 0 0 0 \
		$menulist
	return
}
export -f getselection

#
# pickasctl
#	show a list of storage controller(s) for a vm, let user pick one,
#	return index of the controller
#
pickasctl() {
	[ $# = 1 ] || return 1
	vm="$1"
	title="$vm: Current Storage Controllers"
	ctlList=$(vb_showvminfo -m "$vm" |
		grep '^storagecontrollername' |
		sed -e 's/^storagecontrollername//' -e 's/ /_/' -e 's/=/ /')
	if [ -n "$ctlList" ] 
	then
		vbdlg "$title" \
			--menu 'Select a Storage Controller, or <Cancel> to return' 0 0 0 $ctlList
		return
	else
		vbdlg "$title" --msgbox 'There are no Storage Controllers!' 5 44
		return 1
	fi
}
export -f pickasctl

#
# getsctlname
#	return name of controller for a VM
#	$1	VM
#	$2	S/Controller index
#
getsctlname() {
	[ $# = 2 ] || return 1
	getvmpar "$1" "storagecontrollername${2}"
	return
}
export -f getsctlname

#
# getdeffolder
#	get and return the default machine folder
#
getdeffolder() {
	vb_list systemproperties |
		sed -ne 's/Default machine folder:  *//p'
}
export -f getdeffolder

