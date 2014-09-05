#!/bin/bash
#
# vboxmanage.sh
#	mock vboxmanage to be used for testing
#
# Copyright (c) 2014 Fred Youhanaie
#	http://www.gnu.org/licenses/gpl-2.0.html
#

export VBOXMANAGE=1


#
# vb_manage cmd [ args ... ]
#	simulate the vboxmanage command
#
vb_manage() {
	# we need at least a subcommand
	[ $# = 0 ] && return 1
	cmd=$1
	shift
	case "$cmd" in
	list)
		vbman_list "$@"
		;;
	*)
		vbman_default "$cmd" "$@"
		;;
	esac
}
export -f vb_manage


#
# vbman_default
#	mock any VBoxManage command
#
vbman_default() {
	echo "TEST MODE"
	echo "	VBoxManager $@"
	echo "TEST MODE"
}


#
# vbman_list obj
#	simulate the "vb_manage list" command
#
#	We only provide sensible listing for the list commands that
#	are used internally, which need to be added to the first section
#	of the case/esac block.
#
vbman_list() {
	# we need exactly one arg, the object type to list
	[ $# != 1 ] && return 1
	obj=$1
	case "$obj" in
	vms|ostypes|systemproperties)
		vbman_list_$obj
		;;
	*)
		vbman_list_default
		;;
	esac
}
export vbman_list


#
# vbman_list_default
#	produce a mock list for the default case
#
vbman_list_default() {
	cat <<%
Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod
tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim
veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea
commodo consequat. Duis aute irure dolor in reprehenderit in voluptate
velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat
cupidatat non proident, sunt in culpa qui officia deserunt mollit anim
id est laborum.
%
	return
}


#
# vbman_list_vms
#	produce a mock list of virtual boxes
#
vbman_list_vms() {
	cat <<%
"SDN-VM_32bit" {ec527fac-c8b9-40c3-9a33-ad34212d24e0}
"learn_puppet_master_0" {6e35f00b-9f98-42d1-8749-5b4d9d4fb3c4}
"learn_puppet_agent_1" {db198f7b-011f-4ed6-9a40-e16fac0a52c7}
%
	return
}


#
# vbman_list_ostypes
#	produce a mock list of OS types
#
vbman_list_ostypes() {
	cat <<%
ID:          Linux24_64
Description: Linux 2.4 (64 bit)
Family ID:   Linux
Family Desc: Linux
64 bit:      true

ID:          Linux26
Description: Linux 2.6 / 3.x (32 bit)
Family ID:   Linux
Family Desc: Linux
64 bit:      false

ID:          Linux26_64
Description: Linux 2.6 / 3.x (64 bit)
Family ID:   Linux
Family Desc: Linux
64 bit:      true

ID:          ArchLinux
Description: Arch Linux (32 bit)
Family ID:   Linux
Family Desc: Linux
64 bit:      false
%
	return
}


#
# vbman_list_systemproperties
#	produce a mock list of OS types
#
vbman_list_systemproperties() {
	cat <<%
API version:                     4_3
Minimum guest RAM size:          4 Megabytes
Maximum guest RAM size:          2097152 Megabytes
Minimum video RAM size:          1 Megabytes
Maximum video RAM size:          256 Megabytes
Maximum guest monitor count:     64
Minimum guest CPU count:         1
Maximum guest CPU count:         32
Virtual disk limit (info):       2199022206976 Bytes
Maximum Serial Port count:       2
Maximum Parallel Port count:     2
Maximum Boot Position:           4
Maximum PIIX3 Network Adapter count:   8
Maximum ICH9 Network Adapter count:   36
Maximum PIIX3 IDE Controllers:   1
Maximum ICH9 IDE Controllers:    1
Maximum IDE Port count:          2
Maximum Devices per IDE Port:    2
Maximum PIIX3 SATA Controllers:  1
Maximum ICH9 SATA Controllers:   8
Maximum SATA Port count:         30
Maximum Devices per SATA Port:   1
Maximum PIIX3 SCSI Controllers:  1
Maximum ICH9 SCSI Controllers:   8
Maximum SCSI Port count:         16
Maximum Devices per SCSI Port:   1
Maximum SAS PIIX3 Controllers:   1
Maximum SAS ICH9 Controllers:    8
Maximum SAS Port count:          8
Maximum Devices per SAS Port:    1
Maximum PIIX3 Floppy Controllers:1
Maximum ICH9 Floppy Controllers: 1
Maximum Floppy Port count:       1
Maximum Devices per Floppy Port: 2
Default machine folder:          /usr/local/VirtualBox_VMs
Exclusive HW virtualization use: on
Default hard disk format:        VDI
VRDE auth library:               VBoxAuth
Webservice auth. library:        VBoxAuth
Remote desktop ExtPack:          Oracle VM VirtualBox Extension Pack
Log history count:               3
Default frontend:                
Autostart database path:         
Default Guest Additions ISO:     /usr/share/virtualbox/VBoxGuestAdditions.iso
%
	return
}

