#!/usr/bin/env nu

def maybe-commit [scope: string, path: string] {
    if (git status --porcelain $path | is-not-empty) {
        git add $path
        git commit -m $"($scope): update"
    }
}

def fetch-npins [scope: string, commit: bool] {
    let path = $"pkgs/($scope)/npins"
    ^npins -d $path update
    if $commit {
        maybe-commit $scope $path
    }
}

def fetch-firefox [commit: bool] {
    let generated_path = "pkgs/firefoxAddons/_generated.nix"
    ^mozilla-addons-to-nix pkgs/firefoxAddons/addons.json $generated_path
    if $commit {
        maybe-commit "firefoxAddons" $generated_path
    }
}

def fetch [package: string, commit: bool] {
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

    if $commit {
        let base_path = "pkgs/" + ($package | str replace "." "/")
        mut path = $base_path + ".nix"

        if not ($path | path exists) {
            $path = $base_path + "/package.nix"
        }

        maybe-commit $package $path
    }
}

def main [--commit, ...packages: string] {
    let npins_scopes = ["emacsPackages", "vimPlugins", "xplrPlugins", "yaziPlugins"]
    if ($packages | is-empty) {
        $npins_scopes | par-each {|scope| fetch-npins $scope $commit}
        fetch-firefox $commit

        let update_scripts = nix eval .#_UPDATABLE --json | from json
        let failures = $update_scripts | each {|package|
            try {
                fetch $package $commit
                null
            } catch {
                $package
            }
        } | compact
        if "GITHUB_STEP_SUMMARY" in $env and ($failures | is-not-empty) {
            "# Failed" | save --append $env.GITHUB_STEP_SUMMARY
            $failures | each {|package|
                $"\n- `($package)`" | save --append $env.GITHUB_STEP_SUMMARY
            }
        }
    } else {
        for $package in $packages {
            if $package in $npins_scopes {
                fetch-npins $package $commit
            } else {
                match $package {
                    "firefoxAddons" => { fetch-firefox $commit }
                    _ => { fetch $package $commit }
                }
            }
        }
    }
}
