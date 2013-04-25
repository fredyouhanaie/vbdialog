#!/bin/bash

# vbfunctions.sh
#	common shell functions

export VBFUNCTIONS=1	# so that

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
	eval "dialog --stdout --default-item Linux26 \
		--menu 'Select OS type, or <Cancel> to return' 0 0 0" \
		$(getoslist)
	return $?
}
export -f getostype

