#!/bin/bash
#
# vb-showvminfo.sh
#	interactive showvminfo
#
# Copyright (c) 2013 Fred Youhanaie
#	http://www.gnu.org/licenses/gpl-2.0.html
#

pdir=$(dirname $0)
pname=$(basename $0)

#
#	set the background title, unless already set by caller
#
: ${backtitle:="Virtual Box"}
backtitle="$backtitle - Show VM Information"

VBSHOW='VBoxManage showvminfo '

while :
do
	vm=$(pickavm)
	[ $? = 0 ] || break
	tmpfile=$(mktemp) &&
	$VBSHOW "$vm" >$tmpfile &&
	dialog --backtitle "$backtitle" --title "showvminfo $vm" --textbox $tmpfile 0 0 &&
	rm $tmpfile
done

clearexit 0
