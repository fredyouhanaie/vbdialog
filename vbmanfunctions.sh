#!/bin/bash
#
# vbmanfunctions.sh
#	common shell functions that wrap VBoxManage
#
# Copyright (c) 2013 Fred Youhanaie
#	http://www.gnu.org/licenses/gpl-2.0.html
#

pdir=$(dirname $0)

export VBMANFUNCTIONS=1

##[ -n "$VBFUNCTIONS" ] || source $pdir/vbfunctions.sh

#
# vbman
#	A wrapper for VBoxManage
#	Allows to control which VBoxManage sub-commands are run.
#	can be used to log every single call.
#
vbman() {
	[ $# -gt 1 ] || return 1
	if [ -n "$VBTEST" ]
	then
		[ -n "$VBOXMANAGE" ] || source $pdir/vboxmanage.sh
		vb_manage "$@"
	else
		VBoxManage "$@"
	fi
}
export -f vbman


#
# vbmancreatehd <hdfile> <hdsize> <hdformat>
#	createhd wrapper
#
# Given the filename, size and format, create a hard disk.
#
vb_createhd() {
	[ $# = 3 ] || return 1
	vbman createhd --filename "$1" --size "$2" --format "$3"
}
export -f vb_createhd


#
# vb_createvm <name> <ostype>
#	createvm wrapper
#
# Given the vmname and ostype, create and register a vm.
#
vb_createvm() {
	[ $# = 2 ] || return 1
	vbman createvm --filename "$1" --size "$2" --format "$3"
}
export -f vb_createvm


#
# vb_deletevm <vmname>
#	completely remove a vm
#
vb_deletevm() {
	[ $# = 1 ] || return 1
	vbman unregistervm --delete "$1"
}
export -f vb_deletevm


# vb_list <choice>
#	run the vboxmanage list command
#
vb_list() {
	[ $# = 1 ] || return 1
	vbman list "$1"
}
export -f vb_list


# vb_modifyvm <vmname> <param> <value>
#	vboxmanage modifyvm $vmname --$param $value
#
vb_modifyvm() {
	[ $# = 3 ] || return 1
	vbman modifyvm "$1" "--$2" "$3"
}
export -f vb_modifyvm


#
# vb_showvminfo [ -m ] <vmname>
#	run showvminfo 
#
vb_showvminfo() {
	[ $# = 1 -o $# = 2 ] || return 1
	[ $# = 2 -a "$1" != '-m' ] && return 1
	cmd="vbman showvminfo '$vmname'"
	[ $# = 2 ] && cmd="$cmd --machinereadable"
	eval "$cmd"
}
export -f vb_showvminfo


#
# vb_stattach <vm> <ctlname> <port> <dev> <dtype> <medium>
#	attach a storage medium to a controller
#
vb_stattach() {
	[ $# = 6 ] || return 1
	vbman storageattach "$1" --storagectl "$2" --port "$3" \
		--device "$4" --type "$5" --medium "$6"
}
export -f vb_stattach


# addstctl vmname ctlname ctltype ctlchip
#	run storagectl $vmname --name $ctlname --add $ctltype --controller $ctlchip
#
vb_addstctl() {
	[ $# = 4 ] || return 1
	vbman "$1" --name "$2" --add "$3" --controller "$4"
}
export -f vb_addstctl


# modifystctl <vmname> <ctlname> <bootable> <controller> <portcount>
#	modify an exiting controller configuration
#
vb_modstctl() {
	[ $# = 5 ] || return 1
	vbman storagectl "$1" --name "$2" --bootable "$3" --controller "$4" --portcount "$5"
}
export -f vb_modstctl


# vb_delsctl vmname ctlname
#	delete a storage controller
#
vb_delstctl() {
	[ $# = 2 ] || return 1
	vbman storagectl "$1" --name "$2" --remove
}
export -f vb_delstctl

 
