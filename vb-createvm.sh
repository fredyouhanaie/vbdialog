#!/bin/bash

# vb-createvm.sh
#	interactively create a VM.

pdir=`dirname $0`
pname=`basename $0`

#
#	set the background title, unless already set by caller
#
: ${backtitle:="Virtual Box"}
backtitle="$backtitle - Create VM"

dialog --backtitle "$backtitle" --title "createvm" --msgbox "Sorry, not implemented yet!" 0 0

clear
echo "$pname: Terminated!" >&2
