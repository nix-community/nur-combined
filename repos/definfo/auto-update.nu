#!/usr/bin/env -S nix shell nixpkgs#nushell nixpkgs#nix-update --command nu

let SYSTEM = (nix eval --impure --raw --expr 'builtins.currentSystem')
let PKGS = (nix eval --raw $".#packages.($SYSTEM)" --apply 'attrs: builtins.toString (builtins.attrNames attrs)' | split row ' ')
let EXCLUDED_PKGS = [ sarasa-term-sc-nerd sjtu-canvas-helper ]

let UPDATE_ARGS = {
    # custom version format
    aya-prover: ["--version-regex=v(.*)"]
    # sjtu-canvas-helper: ["--version-regex=app-v(.*)"]
    smartdns-rs: ["--version-regex=v(.*)"]
    waylrc: ["--flake" "--version-regex=v(.*)"]
    # unstable update
    dnsmasq-china-list_smartdns: ["--version=branch"]
    nsub: ["--version=branch"]
    sail: ["--version=branch"]
    isla-sail: ["--version=branch"]
}

def update_package [pkg: string, verbose: bool] {
    print $"Updating ($pkg) ..."

    # Check if package file exists
    let pkg_file = $"pkgs/($pkg)/default.nix"
    if not ($pkg_file | path exists) {
        print $"Warning: ($pkg_file) not found, skipping git status check."

        # Get update arguments for this package
        let args = ($UPDATE_ARGS | get -i $pkg | default [])

        # Run nix-update anyway
        let update_result = try {
            if ($args | is-empty) {
                ^nix-update $pkg | complete
            } else {
                ^nix-update $pkg ...$args | complete
            }
        } catch { |e|
            print $"Error updating ($pkg): ($e.msg)"
            return
        }

        if $update_result.exit_code != 0 {
        print $"Error updating ($pkg): program exited with error ($update_result.exit_code)\):"
            print $update_result.stderr
        } else {
            print $"Update command completed for ($pkg)."
            if $verbose and not ($update_result.stdout | is-empty) {
                print $"nix-update output:"
                print $update_result.stdout
            }
        }
        return
    }

    let hash_before = (open $pkg_file | hash sha256)

    let args = ($UPDATE_ARGS | get -i $pkg | default [])

    let update_result = try {
        if ($args | is-empty) {
            ^nix-update $pkg | complete
        } else {
            ^nix-update $pkg ...$args | complete
        }
    } catch { |e|
        print $"😾 Error updating ($pkg): ($e.msg)"
        return
    }

    if $update_result.exit_code != 0 {
        print $"😾 Error updating ($pkg): program exited with error ($update_result.exit_code):"
        print $update_result.stderr
        return
    } else if $verbose {
        if not ($update_result.stdout | is-empty) {
            print $"nix-update output for ($pkg):"
            print $update_result.stdout
        }
        if not ($update_result.stderr | is-empty) {
            print $"nix-update stderr for ($pkg):"
            print $update_result.stderr
        }
    }

    let hash_after = (open $pkg_file | hash sha256)

    if $hash_before == $hash_after {
        print $"🐖 No update needed for ($pkg)."
    } else {
        print $"🐖 Successfully updated ($pkg)."
    }
}

def main [--verbose (-v) = false] {
    for pkg in $PKGS {
        if $pkg not-in $EXCLUDED_PKGS {
            update_package $pkg $verbose
        }
    }
}
