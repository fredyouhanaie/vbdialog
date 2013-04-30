
# vbdialog

A set of dialog/curses based shell scripts for `VBoxManage`.

The purpose of this project is not to create a super interface for Virtual
Box, but rather a non-GUI screen based interface to save myself typing
long `VBoxManage` commands.

The main script is `vbdialog`, which provides a menu for launching
various command sub-menus.

Each of the sub-menus are implemented as `vb-*.sh` scripts in the same
directory as `vbdialog`.

There is also a vbdialogrc file that controls the appearance of the
various `dialog` widgets. This file is expected to be in same directory
as the commands.

## Installation

There are no build/install scripts. It is just a matter of putting the
scripts in a suitable directory and then running `vbdialog`. For example

	cd vbdialog
	mkdir -pv /usr/local/lib/vbdialog
	cp -vip vbdialog vbdialogrc vb-*.sh /usr/local/lib/dbdialog
	alias vbd=/usr/local/lib/vbdialog/vbdialog

Then use `vbd` to get the main menu.

## Testing

The scripts have been manually tested against Virtual Box 4.2.12, on
Debian 6.0 (Squeeze). I am investigating methods of automating the tests,
perhaps using tools such as expectk.

## Documentation

This file IS the documentation, everything else should be
self-explanatory.

## Feedback

All feedback are welcome, in the form of github issue tracker and/or
pull requests.

Please do bear in mind that simplicity and convenience are the main
drivers of this project. The intention is to create a personal tool,
rather than a super-duper interface full of features.


Enjoy!

Fred Youhanaie

