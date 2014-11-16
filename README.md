
# vbdialog

## Introduction

[VirtualBox](http://virtualbox.org) provides two main interfaces for
configuring and controlling virtual boxes, `VirtualBox` and `VBoxManage`,
a GUI and a CLI respectively.

The GUI is full featured, however, if the server hosting the virtual
boxes is elsewehere on the LAN, or even WAN, then the GUI response times
may suffer.

On the other hand, the CLI is flexible enough that it can be used by
logging in to the remote server, say with ssh, and working at the shell
level. However, the single CLI command has many subcommands some of
which with a large number of options. Typing incomplete commands will
produce a usage listing, but that does not help, since the usage listings
are just far too long. For example the usage listing for `VBoxManage`
is just under 600 lines, or about 10 A4 pages! And the usage listing for
`VBoxManage modifyvm` subcommand is over 130 lines long. Of course one can
always create wrapper scripts and shell aliases to overcome this problem.

`vbdialog` provides a user interface that fills the gap between these
two extremes by providing a text based visual interface, while being
lightweight when used across the network. It is similar to creating
wrapper scripts for the frequently used subsets of the `VBoxManage`
subcommands and accessing them through a screen based menus and forms.

## Implementation notes

Originally, the project was created as a time saving device when working
with virtual boxes over the network, and it was expected to be no more
than 200-300 lines of bash scripts. However, the total size has now
exceeded 1300 lines, so the project clearly needs a rethink and redesign,
both of which are in progress. If you are using the program your feedback
is welcome :-)

The purpose of the project is not to create a super interface for Virtual
Box, but rather a non-GUI screen based interface to save one typing long
`VBoxManage` commands.

The core of the interface is the [dialog](http://invisible-island.net/dialog/dialog.html) program, which in turn uses the [ncurses](http://invisible-island.net/ncurses/ncurses.html) library to create the menus and forms. Dialog and ncurse packages are available on most Linux distributions, and probably most Unix-like operating systems. Otherwise, you may need to download and build locally.

The main script is `vbdialog`, which provides a menu for launching
various command sub-menus.

Each of the sub-menus are implemented as `vb-*.sh` scripts in the same
directory as `vbdialog`.

There is also a vbdialogrc file that controls the appearance of the
various `dialog` widgets. This file is expected to be in the same
directory as the commands.

## Installation

There are no build/install scripts. It is just a matter of putting the
scripts in a suitable directory and then running `vbdialog`. For example,
once you have the software downloaded/cloned:

	cd vbdialog
	mkdir -pv /usr/local/lib/vbdialog
	cp -vip vbdialog vbdialogrc vb*.sh /usr/local/lib/vbdialog
	alias vbd=/usr/local/lib/vbdialog/vbdialog

Then use `vbd` to get the main menu.

## Testing

The scripts have been manually tested against Virtual Box 4.3.18, on
Debian 7.0 (Wheezy). I am investigating methods of automating the tests,
perhaps using tools such as expectk.

## Documentation

This file is all the documentation, everything else should, hopefully,
be self-explanatory. Feel free to drop me a line, if you need further
documentation.

## Feedback and Contributions

All feedback and contributions are welcome, in the form of github issue
tracker and/or pull requests.

Please do bear in mind that simplicity and convenience are the main
drivers of this project. The intention is to create a personal tool,
rather than a super-duper interface full of features.


Enjoy!

Fred Youhanaie

