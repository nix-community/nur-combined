#!/usr/bin/env nu

# A Nushell script to resolve mDNS hostnames for WireGuard endpoints
# and restart the interface if the IP address changes and the old link is down.
#
# Usage:
#   ./wg-mdns-resolver.nu /path/to/config.toml

def main [
    config_path: path # The path to the TOML configuration file
] {
    use std log;
    # --- Configuration ---
    # Directory to store the last known IP addresses.
    let state_file = "/tmp/wg-keeper.json"
    touch $state_file

    # --- Load and Parse Config ---
    if not ($config_path | path exists) {
        error make { msg: $"Config file not found: ($config_path)" }
        return
    }
    let config = open $config_path

    # --- Filter for Target Nodes ---
    # Find nodes that have 'identifiers' but do not have 'addrs'.
    let nodes_to_check = $config.node
        | transpose name value
        | where {|it| $it.name != (hostname | str trim)}
        | where {|it| 'identifiers' in $it.value and not ('addrs' in $it.value) }

    if ($nodes_to_check | is-empty) {
        log info "No nodes with mDNS identifiers and without static addresses found. Exiting."
        return
    }

    # --- Process Each Node ---
    for node in $nodes_to_check {
        let node_name = $node.name
        let device_name = $"hts-($node_name)"
        let hostname = $node.value.identifiers.0.name

        log info $"Processing node: ($node_name) | Host: ($hostname) | Device: ($device_name)"

        # --- Resolve Hostname ---
        # Resolve the hostname to an IPv6 address using dig.
        # We wrap this in a `do` block to catch potential resolution errors.
        # It takes the first line of the output as the IP.
        let new_ip = try {
            do --capture-errors { dig +timeout=3 +short $hostname AAAA } | rg -v '^fe80:' | str trim | lines | first
        } catch {
            log info "dig error. pass"
            continue 
        }

        # If resolution fails, `new_ip` will be null.
        if ($new_ip == null) {
            log error $"Could not resolve hostname '($hostname)' for node '($node_name)'. Skipping."
            continue
        }

        # --- Get Old State ---
        # Load the last known IP from the state file, if it exists.
        let state = if ($state_file|path exists) {
            open $state_file
        } else {
            null
        }

        let old_ip = if $state != null { $state | get -o $node_name | default null } else { null };

        # --- Compare and Act ---
        # Proceed only if the IP has actually changed.
        if $new_ip == $old_ip {
            log info $"IP for ($node_name) is unchanged: ($new_ip). No action taken."
        } else if $old_ip == null {
            log info $"old ip for ($node_name) not found, write state file then skip"
            if $state == null {
                {$node_name: $new_ip} | save --force $state_file
            } else {
                $state | upsert $node_name $new_ip | save --force $state_file
            }
            continue
        } else {
            log info $"IP for ($node_name) has changed: old: ($old_ip | default 'none') -> new: ($new_ip)."

            let is_old_conn_down = do {
                log info $"pinging ($old_ip)"
                (ping -6 -c 1 -w 2 $old_ip | complete).exit_code != 0
            }

            if $is_old_conn_down {
                log info "Old connection appears to be down. Restarting interface..."
                try {
                    ip link del dev $device_name
                    networkctl reload
                    log info $"Successfully restarted interface '($device_name)'."
                } catch {
                    log  error $"Error: Failed to restart interface '($device_name)'. Check permissions and logs."
                }
            } else {
                print "Old connection to ($old_ip) is still active. Deferring restart."
            }

            # --- Update State File ---
            # Save the newly resolved IP to the state file for the next run.
            if $state == null {
                {$node_name: $new_ip} | save --force $state_file
            } else {
                $state | upsert $node_name $new_ip | save --force $state_file
            }
            log info $"Updated state for ($node_name) with new IP: ($new_ip)"
        }
        print "" # Add a blank line for readability
    }
}
