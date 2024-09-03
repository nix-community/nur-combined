set shell := ["nu", "-c"]

alias c := check
alias b := build
alias d := deploy
alias de := decrypt
alias en := encrypt-new
alias chk:= check
alias ee := edit-sec
alias r  := rekey

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
    nix eval --impure --expr "(with builtins; (filter (n: !(elem n [\"resq\"]))
        (attrNames (getFlake (toString ./.) ).nixosConfigurations)))"
    | str replace -a '"' ''
    | str replace '[ ' ''
    | str replace ' ]' ''
    | str trim
    | split row ' '
    | par-each { || nix build $'.#nixosConfigurations.($in).config.system.build.toplevel' -L; }

build *args:
    #!/usr/bin/env nu
    use {{loc}}/util.nu
    f b {{ args }}

deploy *args:
    #!/usr/bin/env nu
    use {{loc}}/util.nu
    f d {{ args }}

encrypt-new *args:
    #!/usr/bin/env nu
    let age_pub = "/run/agenix/age"
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
    let age_pub = "/run/agenix/age"
    let origin_file_to_enc = ['./sec' '{{ home }}/Sec']
                                  | each {|| ls $in } | flatten | $in.name |
                                  reduce {|it, acc| $it + (char newline) + $acc } |
                                  fzf
    rage -e $origin_file_to_enc -i $age_pub -i {{ yubikey-ident }} -o $'($origin_file_to_enc).age'
    srm -C $origin_file_to_enc

edit-sec *args:
    #!/usr/bin/env nu
    let age_pub = "/run/agenix/age"
    let encrypted_file_tob_edit = ['./sec' '{{ home }}/Sec']
                                  | each {|| ls $in } | flatten | $in.name |
                                  reduce {|it, acc| $it + (char newline) + $acc } |
                                  fzf
    if (not ($encrypted_file_tob_edit | path exists)) { print -e "Not found"; exit }
    let tmp_file = (mktemp -t)
    rage -d $encrypted_file_tob_edit -i $age_pub -o $tmp_file
    let pre_hash = b3sum --no-names $tmp_file
    print $pre_hash
    hx $tmp_file
    let after_hash = b3sum --no-names $tmp_file
    if ($pre_hash != $after_hash) {
      rage -e $tmp_file -i $age_pub -i {{ yubikey-ident }} -o $encrypted_file_tob_edit
    } else {
      print $after_hash "file not change"
    }
    srm -C $tmp_file

decrypt *args:
    #!/usr/bin/env nu
    use {{loc}}/util.nu
    ['./sec' '{{ home }}/Sec'] |
      each {|| ls $in } | flatten | $in.name |
              reduce {|it, acc| $it + (char newline) + $acc } | fzf | str trim | f de $in

remote-switch *args:
    #!/usr/bin/env nu
    use {{loc}}/util.nu
    f rswc {{ args }}

check:
    #!/usr/bin/env nu
    use {{loc}}/util.nu
    f chk

rekey:
    agenix rekey -a

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
