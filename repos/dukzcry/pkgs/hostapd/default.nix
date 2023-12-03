{ writeScriptBin, lib }:

writeScriptBin "hostapd.sh" (lib.readFile ./hostapd.sh)
