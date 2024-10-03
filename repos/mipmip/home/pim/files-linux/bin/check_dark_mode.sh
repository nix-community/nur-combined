#!/usr/bin/env bash
[[ `gsettings get org.gnome.desktop.interface color-scheme` =~ 'dark' ]] && echo dark || echo light
