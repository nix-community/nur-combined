#!/usr/bin/env nu

export-env {
  $env.get_addr = { |map, per| $map | get $per | $in.addr }
  $env.get_user = { |map, per| $map | get $per | $in.user }
  $env.map = open ./hosts/sum.toml | $in.node
}

export def br [
  nodes?: list<string>
  --builder (-b): string = "hastur"
] {

  let target_addr = do $env.get_addr ($env.map) $builder

  let h = hostname | str trim

  let job = if $h != $builder {
    ["--max-jobs" "0"]
  } else { [] }

  let machine_spec = "x86_64-linux - - - big-parallel"

  $nodes | par-each {|| 
    (nix build $'.#nixosConfigurations.($in).config.system.build.toplevel'
      --builders $"($target_addr) ($machine_spec)"
      ...($job) -vvv) 
  }

}

# build
export def b [
  nodes?: list<string>
] {

  $nodes | par-each {|| 
    (nom build $'.#nixosConfigurations.($in).config.system.build.toplevel')
  }

}

# deploy
# all op with hostname
export def d [
  nodes?: list<string>
  mode?: string = "switch"
  --builder: string
  --sod
] {

  let get_addr = {|x| do $env.get_addr ($env.map) ($x)}
  let get_user = {|x| do $env.get_user ($env.map) ($x)}

  let machine_spec = "i686-linux,x86_64-linux - - - big-parallel"
  let extra_builder_args = if ($builder != null) { [--max-jobs 0 --builders $'(do $get_addr $builder) ($machine_spec)'] } else {[]}
  print $extra_builder_args

  if ($nodes == null or $nodes == []) {
    (nh os $mode . -- ...($extra_builder_args))
  } else {
    use std log;

    $nodes | each {|per|
      let per_node_addr = do $get_addr $per;
      let user = do $get_user $per;

      nixos-rebuild switch --flake . --target-host $'($user)@($per_node_addr)' --sudo
    
    }
  }
}

const age_pub = "/run/vaultix/age"


# decrypt
export def de [path: string] {
  let tmp_path = (mktemp -t)
  rage -d $path -i $age_pub -o $tmp_path # -i ./age-yubikey-identity-7d5d5540.txt.pub
  let mime_type = (xdg-mime query filetype $tmp_path)
  if ($mime_type | str contains "image") {
    cat $tmp_path | img2sixel
  } else {
    cat $tmp_path
  }

  srm -C $tmp_path
}

export def dump [path?: string = "./sec/decrypted"] {
  srm -frC $path
  mkdir $path
  ls ./sec/*.age | par-each {|i| 
    de $i.name | save $'($path)/($i.name | path parse | $in.stem)' 
  }
}

export def chk [] {
  let allow = ["f" "age-yubikey-identity-7d5d5540.txt.pub" "rekeyed"]
  ls sec |
    filter {|i|
      not ($in.name | path basename | str ends-with "age")
    } |
    filter {|i|
      not ($i.name | path basename | $in in $allow)
    }
}
