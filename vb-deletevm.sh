#!/bin/bash
#
# vb-deletevm
#	Delete a VM
#
# Copyright (c) 2013 Fred Youhanaie
#	http://www.gnu.org/licenses/gpl-2.0.html
#

pdir=`dirname $0`
pname=`basename $0`

[ -n "$VBFUNCTIONS" ] || source $pdir/vbfunctions.sh

#
#	set the background title, unless already set by caller
#
: ${backtitle:="Virtual Box"}
backtitle="$backtitle - Delete VM"

VBDELETE='VBoxManage unregistervm --delete'

while :
do
	vm=`pickavm`
	[ $? = 0 ] || break
	runcommand "Ready to Delete VM?" "$VBDELETE $vm"
	[ $? = 0 ] && break
done

clearexit 0
