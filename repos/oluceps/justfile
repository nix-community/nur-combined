set shell := ["nu", "-c"]

alias c := check
alias b := build
alias d := deploy
alias de := decrypt
alias en := encrypt-new
alias chk:= check
alias ee := edit-sec
alias r  := renc
alias s  := search-history

yubikey-ident := './sec/age-yubikey-identity-7d5d5540.txt.pub'

host := `hostname`
me := `whoami`
loc := `pwd`
home := `$env.HOME`

default:
    @just --choose

build-livecd:
    nom build .#nixosConfigurations.livecd.config.system.build.isoImage --impure

build-cache:
    nix shell -f '<nixpkgs>' nix-build-uncached -c nix-build-uncached ci.nix -A cacheOutputs

build-bootstrap:
    nom build .#nixosConfigurations.bootstrap.config.system.build.diskoImages
test-bootstrap:
    nix run github:nix-community/nixos-anywhere -- --flake .#bootstrap --vm-test

build-all-host:
    #!/usr/bin/env nu
    open registry.toml | $in.node | columns
    | par-each { || nix build $'.#nixosConfigurations.($in).config.system.build.toplevel' -L; }
renc:
    just sync-subsec
    touch .nix-dirty
    git add -N .nix-dirty
    nix run $'.#vaultix.app.(uname | $'($in.machine)-($in.kernel-name | str downcase)').renc'
    just sync-subsec
    git add ./sec
    rm .nix-dirty
    git rm --cache .nix-dirty

[working-directory: 'sec']
sync-subsec:
    just sec-submodule-add
    try { git commit -m "vaultix: sechange" }

[working-directory: 'sec']
sec-submodule-add:
    git add .


build:
    #!/usr/bin/env nu
    use {{loc}}/util.nu
    open registry.toml | $in.node | columns
    | reduce {|it, acc| $it + (char newline) + $acc }
    | gum choose --no-limit
    | split words
    | util b $in

deploy:
    #!/usr/bin/env nu
    use {{loc}}/util.nu
    open registry.toml | $in.node | columns
    | reduce {|it, acc| $it + (char newline) + $acc }
    | gum choose --no-limit
    | split words
    | util d $in
deploy-boot:
    #!/usr/bin/env nu
    use {{loc}}/util.nu
    open registry.toml | $in.node | columns
    | reduce {|it, acc| $it + (char newline) + $acc }
    | gum choose --no-limit
    | split words
    | util d $in boot

encrypt-new *args:
    #!/usr/bin/env nu
    const age_pub = "/run/vaultix/age"
    let output_dir = ['./sec/' '{{ home }}/Sec/'] |
                       reduce {|it, acc| $it + (char newline) + $acc } | fzf
    echo "input file name: "
    let name = (input)
    let tmp_path = (mktemp -t)
    hx $tmp_path
    rage -e $tmp_path -i $age_pub -i {{ yubikey-ident }} -o $'($output_dir)($name).age'
    srm -C $tmp_path

encrypt-exist *args:
    #!/usr/bin/env nu
    let age_pub = "/run/vaultix/age"
    let origin_file_to_enc = ['./sec' '{{ home }}/Sec']
                                  | each {|| ls $in } | flatten | $in.name |
                                  reduce {|it, acc| $it + (char newline) + $acc } |
                                  fzf
    rage -e $origin_file_to_enc -i $age_pub -i {{ yubikey-ident }} -o $'($origin_file_to_enc).age'
    srm -C $origin_file_to_enc

edit-sec *args:
    #!/usr/bin/env nu
    let age_pub = "/run/vaultix/age"
    let encrypted_file_tob_edit = ['./sec' '{{ home }}/Sec']
                                  | each {|| ls $in } | flatten | $in.name |
                                  reduce {|it, acc| $it + (char newline) + $acc } |
                                  fzf
    if (not ($encrypted_file_tob_edit | path exists)) { print -e "Not found"; exit }
    nix run $'.?submodules=1#vaultix.app.(uname | $'($in.machine)-($in.kernel-name | str downcase)').edit' -- $encrypted_file_tob_edit

decrypt *args:
    #!/usr/bin/env nu
    use {{loc}}/util.nu
    ['./sec' '{{ home }}/Sec'] |
      each {|| ls $in } | flatten | $in.name |
              reduce {|it, acc| $it + (char newline) + $acc } | fzf | str trim | util de $in

check:
    #!/usr/bin/env nu
    use {{loc}}/util.nu
    util chk

update:
    nix flake update --commit-lock-file

update-pkgs:
    nix run nixpkgs#nvfetcher -- --build-dir _sources

overwrite-local:
    mc mirror --overwrite --remove r2/sec/Sec {{ home }}/Sec/

cleanthebucket:
    #!/usr/bin/env nu
    if ((input) == "yes") { srm -frC {{ home }}/Sec/* }
    sudo btrfs sub del /persist/.snapshots/*

resign-all:
    git filter-branch --commit-filter 'git commit-tree -S "$@";' -- --all

search-history *args:
    git log -S {{ args }}

# Distribute the pinned public upstream CA; never fetch the Server's dynamic bundle.
# REALM_TRUST_BUNDLE_DRY=1 performs local validation/planning only (no SSH).
[positional-arguments]
sync-trust-bundle *nodes:
    #!/usr/bin/env nu
    def main [...nodes: string] {
        ^just _sync-trust-bundle pki/realm-spire/upstream-ca.pem pinned ...$nodes
        exit $env.LAST_EXIT_CODE
    }

# Explicit migration-only override: supply a reviewed old+new public CA bundle.
# This never changes the repository anchor or a generation-managed bundle.
[positional-arguments]
sync-trust-bundle-transition bundle +nodes:
    #!/usr/bin/env nu
    def main [bundle: string, ...nodes: string] {
        ^just _sync-trust-bundle $bundle transition ...$nodes
        exit $env.LAST_EXIT_CODE
    }

[private]
[positional-arguments]
_sync-trust-bundle bundle mode *nodes:
    #!/usr/bin/env nu
    use {{ loc }}/util.nu

    def main [bundle: string, mode: string, ...nodes: string] {
        if $mode not-in [pinned transition] { error make { msg: "unknown bundle mode" } }
        let text = (open --raw $bundle)
        if ($text | str contains "PRIVATE KEY") {
            error make { msg: "refusing material containing a private-key marker" }
        }
        let certs = ($text | parse --regex '(?s)(?P<pem>-----BEGIN CERTIFICATE-----.*?-----END CERTIFICATE-----)')
        let remainder = ($certs | reduce --fold $text {|cert, rest| $rest | str replace --all $cert.pem "" } | str trim)
        if ($certs | is-empty) or ($remainder | is-not-empty) {
            error make { msg: "expected only PEM CERTIFICATE blocks and whitespace" }
        }
        if $mode == "pinned" and ($certs | length) != 1 {
            error make { msg: "the permanent bootstrap must contain only the dedicated upstream intermediate" }
        }
        if $mode == "transition" and ($certs | length) < 2 {
            error make { msg: "transition mode requires an explicitly reviewed old+new CA bundle" }
        }

        # Prefer an explicit executable or PATH. Otherwise resolve the locked
        # project's OpenSSL output offline, without downloading or building it.
        let openssl = if ($env.REALM_OPENSSL? | default "") != "" {
            $env.REALM_OPENSSL
        } else if (which openssl | is-not-empty) {
            (which openssl | first | get path)
        } else {
            let resolved = (^nix eval --offline --no-write-lock-file --raw .#nixosConfigurations.eihort.pkgs.openssl.bin.outPath | complete)
            if $resolved.exit_code != 0 {
                error make { msg: "cannot resolve cached OpenSSL; set REALM_OPENSSL to a local openssl executable" }
            }
            let exe = ($resolved.stdout | str trim | path join bin openssl)
            if not ($exe | path exists) {
                error make { msg: "OpenSSL is not cached; provision once with nix build --no-link .#nixosConfigurations.eihort.pkgs.openssl.bin, or set REALM_OPENSSL" }
            }
            $exe
        }
        for cert in $certs {
            let checked = ($cert.pem | ^$openssl x509 -noout -subject -issuer -dates -fingerprint -sha256 -ext basicConstraints -checkend 0 | complete)
            if $checked.exit_code != 0 or not ($checked.stdout | str contains "CA:TRUE") {
                error make { msg: "invalid, expired, or non-CA certificate in public bundle" }
            }
            print ($checked.stdout | str trim)
        }
        let local_hash = ($text | hash sha256)
        print $"($mode) source: ($bundle), ($certs | length) CA certs, sha256 ($local_hash)"

        # Realm membership comes from evaluated config, addresses from registry
        # via the same util mapping as deployment. Include offline enabled nodes.
        let evaluated = (^nix eval --offline --no-write-lock-file --json .#nixosConfigurations --apply 'systems: builtins.filter (name: systems.${name}.config.realm.enable or false) (builtins.attrNames systems)' | complete)
        if $evaluated.exit_code != 0 {
            print -e $evaluated.stderr
            error make { msg: "cannot evaluate Realm node inventory offline" }
        }
        let enabled = ($evaluated.stdout | from json)
        let targets = (if ($nodes | is-empty) { $enabled } else { $nodes } | uniq)
        if ($targets | is-empty) { error make { msg: "no Realm targets" } }
        # Validate the entire selection before any remote operation.
        for node in $targets {
            if $node not-in $enabled or $node not-in ($env.map | columns) {
                error make { msg: $"($node): expected a registry node with realm.enable" }
            }
        }
        let dry_run = (($env.REALM_TRUST_BUNDLE_DRY? | default "0") != "0")
        if $dry_run {
            for node in $targets {
                let addr = (do $env.get_addr ($env.map) $node)
                print $"($node) ($addr): planned; remote path unchecked; skip generation-managed paths, install only legacy runtime path"
            }
            print "dry run: local PEM validation and inventory only; no SSH, writes, or restarts"
            return
        }

        # Inspect the loaded Agent unit's actual generated config, not the local
        # flake's intended path. Refuse unknown layouts instead of guessing.
        let remote_install = r#'set -eu
            start=$(systemctl show spire-agent.service --property=ExecStart --value)
            config=$(printf "%s\n" "$start" | sed -n 's/.*--config=\([^ ;"}]*\).*/\1/p')
            case "$config" in /nix/store/*|/etc/*) ;; *) echo "cannot identify Agent config" >&2; exit 1;; esac
            paths=$(sed -n 's/^[[:space:]]*"trust_bundle_path"[[:space:]]*:[[:space:]]*"\([^"]*\)"[[:space:]]*,*[[:space:]]*$/\1/p' "$config")
            test "$(printf "%s\n" "$paths" | wc -l)" -eq 1
            test -n "$paths"
            resolved=$(readlink -m -- "$paths")
            case "$paths:$resolved" in
                /nix/store/*|/etc/*|*:/nix/store/*|*:/etc/*)
                    hash=$(sha256sum -- "$paths" | cut -d " " -f1)
                    printf "managed\t%s\t%s\n" "$paths" "$hash"
                    exit 0;;
            esac
            test "$paths" = /var/lib/realm-spire/trust-bundle.pem || {
                echo "refusing unrecognized runtime trust_bundle_path: $paths" >&2; exit 1;
            }
            test ! -L "$paths" || { echo "refusing runtime bundle symlink" >&2; exit 1; }
            dir=/var/lib/realm-spire
            umask 077
            mkdir -p "$dir"
            tmp=$(mktemp "$dir/.trust-bundle.pem.XXXXXX")
            trap 'rm -f "$tmp"' EXIT HUP INT TERM
            cat > "$tmp"
            chmod 600 "$tmp"
            chown root:root "$tmp"
            if [ -f "$paths" ] && ! cmp -s "$tmp" "$paths" && [ ! -e "$paths.before-sync" ]; then
                cp -a -- "$paths" "$paths.before-sync"
            fi
            mv -f -- "$tmp" "$paths"
            hash=$(sha256sum -- "$paths" | cut -d " " -f1)
            printf "synced\t%s\t%s\n" "$paths" "$hash"'#

        let results = $targets | each {|node|
            let addr = (do $env.get_addr ($env.map) $node)
            try {
                let remote = ($text | ^ssh -T -o BatchMode=yes -o ConnectTimeout=10 $"root@($addr)" $remote_install | complete)
                if $remote.exit_code != 0 { error make { msg: ($remote.stderr | str trim) } }
                let fields = ($remote.stdout | str trim | split row (char tab))
                if ($fields | length) != 3 or $fields.0 not-in [managed synced] {
                    error make { msg: "unexpected remote result" }
                }
                if $fields.0 == "managed" {
                    print $"($node) ($addr): ($fields.1) is managed by declarative generation; no write"
                }
                if $fields.2 != $local_hash {
                    error make { msg: $"($fields.1): SHA-256 differs; managed paths require a generation update" }
                }
                print $"($node) ($addr): ($fields.0), sha256 ($fields.2)"
                { state: $fields.0 }
            } catch {|e|
                print -e $"($node) ($addr): failed: ($e.msg)"
                { state: "failed" }
            }
        }
        let failed = ($results | where state == "failed" | length)
        if $failed > 0 { error make { msg: $"($failed) targets unresolved; do not treat this as propagation complete" } }
        print "done: bootstrap checked; running Agent/workload dynamic bundle propagation still needs separate verification"
    }

build-topo:
    nix build .#topology.x86_64-linux.config.output
