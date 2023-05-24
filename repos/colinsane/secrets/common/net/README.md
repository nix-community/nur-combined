## to add a new network
- connect to it (via GUI or `iwctl` TUI)
- find it under `/var/lib/iwd`
- `sops ./<NETWORK_NICKNAME>.psk.bin` and paste the contents from `/var/lib/iwd/SSID.psk`
        - in same file: add `# SSID=UNQUOTED_NETWORK_NAME` to the top
