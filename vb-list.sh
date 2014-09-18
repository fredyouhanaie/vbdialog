#!/bin/bash
#
# vb-list.sh
#	repeatedly run the list command via menu
#
# Copyright (c) 2013 Fred Youhanaie
#	http://www.gnu.org/licenses/gpl-2.0.html
#

pdir=$(dirname $0)
pname=$(basename $0)

[ -n "$VBFUNCTIONS" ] || source $pdir/vbfunctions.sh

#
#	set the background title, unless already set by caller
#
: ${backtitle:="Virtual Box"}
backtitle="$backtitle - List"

while :
do
	choice=$(vbdlg 'List Options' --default-item vms \
		--cancel-label 'Return' \
		--menu "<OK> to list selected object, or\n<Return> to main menu" 0 0 0 \
			bridgedifs "" \
			dhcpservers "" \
			dvds "" \
			extpacks "" \
			floppies "" \
			groups "" \
			hddbackends "" \
			hdds "" \
			hostcpuids "" \
			hostdvds "" \
			hostfloppies "" \
			hostinfo "" \
			hostonlyifs "" \
			intnets "" \
			natnets "" \
			ostypes "" \
			runningvms "" \
			systemproperties "" \
			usbfilters "" \
			usbhost "" \
			vms "" \
			webcams "" )
	[ $? = 0 ] || break
	tmpfile=$(mktemp) &&
	vb_list $choice >$tmpfile &&
	vbdlg "list $choice" --textbox $tmpfile 0 0
	[ -f "$tmpfile" ] && rm $tmpfile
done

clearexit 0
