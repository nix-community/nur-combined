#!/bin/bash
HEADPHONE_SINK="alsa_output.usb-Razer_Razer_USB_Sound_Card_00000000-00.analog-stereo"
SPEAKER_SINK="alsa_output.pci-0000_01_00.1.hdmi-stereo-extra1"
CURRENT_SINK=$(pactl get-default-sink)

if [ "$CURRENT_SINK" == "$HEADPHONE_SINK" ]; then
    pactl set-default-sink "$SPEAKER_SINK"
else
    pactl set-default-sink "$HEADPHONE_SINK"
fi
