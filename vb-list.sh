#!/bin/bash

# vb-list.sh
#	repeatedly run the list command via menu

pdir=`dirname $0`
pname=`basename $0`

#
#	set the background title, unless already set by caller
#
: ${backtitle:="Virtual Box"}
backtitle="$backtitle - List"

VBLIST='VBoxManage list '

while :
do
	choice=`dialog \
		--stdout --backtitle "$backtitle" --title "List Options" --default-item vms \
		--menu "Select option, or <Cancel> to return" 0 0 0 \
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
			ostypes "" \
			runningvms "" \
			systemproperties "" \
			usbfilters "" \
			usbhost "" \
			vms "" `
	[ $? = 0 ] || break
	tmpfile=`mktemp` &&
	$VBLIST $choice >$tmpfile &&
	dialog --backtitle "$backtitle" --title "list $choice" --textbox $tmpfile 0 0 &&
	rm $tmpfile
done

clearexit 0
