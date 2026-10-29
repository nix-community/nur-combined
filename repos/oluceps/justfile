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

# Usage: just sync-trust-bundle
#        just sync-trust-bundle abhoth hastur
#        REALM_TRUST_BUNDLE_DRY=1 just sync-trust-bundle
#
# The Server admin socket only listens on eihort, so the bundle is read over the
# existing SSH management path. `bundle show` returns public CA certificates
# only; the recipe refuses to distribute anything containing a private key.
# The file is bootstrap material: a running Agent keeps syncing its bundle from
# the Server, so this only matters when an Agent starts cold, and for nodes that
# still carry an outdated bootstrap root.
#
# Sync the public SPIRE trust bundle from the Server on eihort to the Realm nodes.
sync-trust-bundle *nodes:
    #!/usr/bin/env nu
    use {{ loc }}/util.nu

    let server = "eihort"
    let realm_nodes = ["abhoth" "azasos" "nodens" "yidhra" "hastur" "eihort"]
    let requested = "{{ nodes }}" | str trim
    let targets = if ($requested | is-empty) { $realm_nodes } else { $requested | split words }
    let dry_run = (($env.REALM_TRUST_BUNDLE_DRY? | default "0") != "0")
    let server_addr = (do $env.get_addr ($env.map) $server)

    let bundle = (mktemp -t)
    print $"reading public bundle from ($server) ($server_addr)"
    ^ssh -n $"root@($server_addr)" '/run/current-system/sw/bin/spire-server bundle show -socketPath /run/spire/server/private/api.sock' | save --force $bundle

    let text = (open --raw $bundle)
    if ($text | str length) == 0 { error make { msg: $"no bundle returned by ($server)" } }
    if not ($text | str contains "-----BEGIN CERTIFICATE-----") {
        error make { msg: "server output is not a PEM certificate bundle" }
    }
    if ($text | str contains "PRIVATE KEY") {
        error make { msg: "refusing to distribute material containing a private key" }
    }

    let certs = ($text | lines | where {|l| $l | str contains "BEGIN CERTIFICATE" } | length)
    let local_hash = (^sha256sum $bundle | split row " " | first)
    print $"bundle: ($certs) public certs, ($text | str length) bytes, sha256 ($local_hash)"

    # Install through a rename so a concurrent reader never sees a partial file,
    # keep the previous copy, and print the resulting hash for comparison. The
    # bundle arrives on stdin so only `ssh` is needed; some nodes run without a
    # working sftp subsystem, which breaks `scp`.
    let remote_install = 'set -eu
        dir=/var/lib/realm-spire
        tmp="$dir/.trust-bundle.pem.new"
        mkdir -p "$dir"
        cat > "$tmp"
        chmod 600 "$tmp"
        chown root:root "$tmp"
        if [ -f "$dir/trust-bundle.pem" ] && ! cmp -s "$tmp" "$dir/trust-bundle.pem"; then
            cp -a "$dir/trust-bundle.pem" "$dir/trust-bundle.pem.before-sync"
        fi
        mv -f "$tmp" "$dir/trust-bundle.pem"
        sha256sum "$dir/trust-bundle.pem"'

    let results = $targets | each {|node|
        let addr = (do $env.get_addr ($env.map) $node)
        try {
            if $dry_run {
                print $"($node) ($addr): would install ($certs) certs"
                { state: "planned" }
            } else {
                let remote_hash = (open --raw $bundle | ^ssh $"root@($addr)" $remote_install | str trim | split row " " | first)
                let state = if $remote_hash == $local_hash { "synced" } else { "hash-mismatch" }
                print $"($node) ($addr): ($state) ($remote_hash)"
                { state: $state }
            }
        } catch {|e|
            print -e $"($node) ($addr): failed: ($e.msg)"
            { state: "failed" }
        }
    }

    let failed = ($results | where {|r| $r.state == "failed" or $r.state == "hash-mismatch" } | length)
    if $failed > 0 { error make { msg: $"($failed) targets did not receive the bundle" } }
    if $dry_run {
        print "dry run: nothing installed"
    } else {
        print "done: running Agents keep their own bundle; this file is used on the next cold start"
    }

build-topo:
    nix build .#topology.x86_64-linux.config.output
