#!/bin/bash

# vbfunctions.sh
#	common shell functions

export VBFUNCTIONS=1

#
# getvmpar
#	Given a vm and parameter name, return its current value.
#	Strip away the double-quotes at the beginning and end, if any.
#
getvmpar() {
	[ $# = 2 ] || return
	vm=$1
	par=$2
	VBoxManage showvminfo $vm --machinereadable |
		awk -F= '$1==''"'$par'"'' {print $2}' |
		sed -e 's/^"//' -e 's/"$//'
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
	dialog --backtitle "$backtitle" --title "$title" --aspect 20 \
		--yesno "About to run\n\n$command\n\nOK to proceed?" 0 0
	retvalue=$?
	if [ "$retvalue" = 0 ]
	then
		clear
		echo "$command" >&2
		echo >&2
		$command
		res=$?
		echo >&2
		read -p "[result=$res]	PRESS ENTER TO CONTINUE"
		echo >&2
		return 0
	else
		return 1
	fi
}
export -f runcommand

#
# getoslist
#	generate a list of OS type IDs and quoted descriptions
#
getoslist() {
	VBoxManage list ostypes | egrep '^ID:|^Description:' | sed -e 's/^.*:  *//' |
	while read name
	do
		read desc
		echo "$name \"$desc\""
	done | sort
}
export -f getoslist

#
# getostype
#	Let the user choose an OS type from a menu
#
getostype() {
	defaultos=$1
	: ${defaultos:=Linux26}
	eval "dialog --stdout --default-item "$defaultos" \
		--menu 'Select OS type, or <Cancel> to return' 0 0 0" \
		$(getoslist)
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
	state=`getvmpar $vm nic${nic}`
	[ -n "$state" ] || return
	echo "nic${nic} \"$state\""
	[ "$state" = "none" ] && return
	VBoxManage showvminfo $vm --machinereadable |
		egrep "^nic[^=]+${nic}=" | awk -F= '{print $1 " " $2}'
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
	value=`getvmpar $vm $nicpar`
	[ $? = 0 ] || return 1
	dialog --stdout --backtitle "$backtitle" --title "$vm: $nicpar" \
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
	value=`getvmpar $vm $nicpar`
	[ $? = 0 ] || return 1
	dialog --stdout --backtitle "$backtitle" --title "$vm $nicpar" \
		--form 'Enter a new value, or <Cancel> to return' 0 0 0 \
		"$nicpar" 1 1 "$value" 1 10 10 10
	return
}
export -f modifynic

#
# pickavm
#	let the user pick a vm from the list
#
pickavm() {
	VMLIST=`VBoxManage list vms | sed 's/["{}]//g' | sort`
	dialog --stdout --backtitle "$backtitle" --title "List of current VMs" \
		--menu 'Select a VM, or <Cancel> to return' 0 0 0 $VMLIST
	return
}
export -f pickavm


