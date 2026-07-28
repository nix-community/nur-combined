#!/usr/bin/env bash

source shellvaculib.bash || exit 1

svl_no_args $#

svl_auto_sudo

declare module_name="mt7921e"

svl_verbose_run rmmod --verbose "$module_name"

svl_verbose_run sleep 1

svl_verbose_run modprobe --verbose "$module_name"
