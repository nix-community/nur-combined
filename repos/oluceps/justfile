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
    just sec-submodule-add
    nix run $'.#vaultix.app.(uname | $'($in.machine)-($in.kernel-name | str downcase)').renc'
    just sync-subsec

[working-directory: 'sec']
sync-subsec:
    just sec-submodule-add
    git commit -m "vaultix: sechange"

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

overwrite-s3:
    mc mirror --overwrite --remove {{ home }}/Sec/ r2/sec/Sec
    mc mirror --overwrite --remove {{ loc }}/sec/ r2/sec/credentials

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
build-topo:
    nix build .#topology.x86_64-linux.config.output
