set shell := ["nu", "-c"]

alias c := check
alias b := build
alias d := deploy
alias de := decrypt
alias en := encrypt
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
    nom build .#nixosConfigurations.livecd.config.system.build.isoImage

build-bootstrap:
    nom build .#nixosConfigurations.bootstrap.config.system.build.diskoImages

build *args:
    #!/usr/bin/env nu
    use {{loc}}/f
    f b {{ args }}

deploy *args:
    #!/usr/bin/env nu
    use {{loc}}/f
    f d {{ args }}

encrypt *args:
    #!/usr/bin/env nu
    let age_pub = "/run/agenix/age"
    let output_dir = ['./sec/' '{{ home }}/Sec/'] |
                       reduce {|it, acc| $it + (char newline) + $acc } | fzf
    echo "input file name: "
    let name = (input)
    let raw_path = (mktemp -t)
    hx $raw_path
    rage -e $raw_path -i $age_pub -i {{ yubikey-ident }} -o $'($output_dir)($name).age'
    srm -C $raw_path

edit-sec *args:
    #!/usr/bin/env nu
    let age_pub = "/run/agenix/age"
    let encrypted_file_tob_edit = ['./sec' '{{ home }}/Sec']
                                  | each {|| ls $in } | flatten | $in.name |
                                  reduce {|it, acc| $it + (char newline) + $acc } |
                                  fzf
    let tmp_file = (mktemp -t)
    rage -d $encrypted_file_tob_edit -i $age_pub -o $tmp_file
    hx $tmp_file
    srm -C $encrypted_file_tob_edit
    rage -e $tmp_file -i $age_pub -i {{ yubikey-ident }} -o $encrypted_file_tob_edit
    srm -C $tmp_file

decrypt *args:
    #!/usr/bin/env nu
    use {{loc}}/f
    ['./sec' '{{ home }}/Sec'] |
      each {|| ls $in } | flatten | $in.name |
              reduce {|it, acc| $it + (char newline) + $acc } | fzf | str trim | f de $in

remote-switch *args:
    #!/usr/bin/env nu
    use {{loc}}/f
    f rswc {{ args }}

check:
    #!/usr/bin/env nu
    use {{loc}}/f
    f chk

rekey:
    agenix rekey

update:
    nix flake update --commit-lock-file

overwrite-s3:
    mc mirror --overwrite --remove {{ home }}/Sec/ r2/sec/Sec
    mc mirror --overwrite --remove {{ loc }}/sec/ r2/sec/credentials

overwrite-local:
    mc mirror --overwrite --remove r2/sec/Sec {{ home }}/Sec/

cleanthebucket:
    if ((input) == "yes") { srm -frC {{ home }}/Sec/*a }
