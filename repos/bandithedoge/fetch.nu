#!/usr/bin/env nu

def fetch-emacs [] {
    ^npins -d pkgs/emacsPackages/npins update
}

def fetch-firefox [] {
    ^mozilla-addons-to-nix pkgs/firefoxAddons/addons.json pkgs/firefoxAddons/_generated.nix
}

def fetch-vim [] {
    ^npins -d pkgs/vimPlugins/npins update
}

def fetch-xplr [] {
    ^npins -d pkgs/xplrPlugins/npins update
}

def fetch-yazi [] {
    ^npins -d pkgs/yaziPlugins/npins update
}

def fetch [package: string] {
    let update_script = nix eval $".#($package).updateScript" --json | from json

    if ($update_script | describe) == "string" {
        nix build $".#($package).updateScript"
    }

    # https://github.com/NixOS/nixpkgs/blob/master/pkgs/README.md#how-are-update-scripts-executed
    with-env {
        UPDATE_NIX_NAME: (nix eval $".#($package).name" --raw),
        UPDATE_NIX_PNAME: (nix eval $".#($package).pname" --raw),
        UPDATE_NIX_OLD_VERSION: (nix eval $".#($package).version" --raw),
        UPDATE_NIX_ATTR_PATH: $package,
    } {
        run-external $update_script
    }
}

def main [...packages: string] {
    if ($packages | is-empty) {
        fetch-emacs
        fetch-firefox
        fetch-vim
        fetch-xplr
        fetch-yazi
        let update_scripts = nix eval .#_UPDATABLE --json | from json
        $update_scripts | each {|package| fetch $package }
    } else {
        for $package in $packages {
            match $package {
                emacs => fetch-emacs
                firefox => fetch-firefox
                vim => fetch-vim
                xplr => fetch-xplr
                yazi => fetch-yazi
                _ => { fetch $package }
            }
        }
    }
}
