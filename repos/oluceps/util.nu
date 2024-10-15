#!/usr/bin/env nu

export-env {
  $env.get_addr = { |map, per| $map | where name == $per | $in.addr.0 }
  $env.map = open ./hosts/sum.toml | $in.host
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
  --builder (-b): string = "hastur"
] {

  let get_addr = {|x| do $env.get_addr ($env.map) ($x)}

  let builder_addr = do $get_addr $builder

  if ($nodes == null) {
    (nh os switch .)
  } else {
    use std log;

    $nodes | par-each {|per|
      let per_node_addr = do $get_addr $per;
      let out_path = (nom build $'.#nixosConfigurations.($per).config.system.build.toplevel'
         --no-link --json |
         from json |
         $in.0.outputs.out)

     # --substitute-on-destination
     nix copy  --to $'ssh://($per_node_addr)' $out_path

      log info "copy closure complete";
      return [$per, $per_node_addr, $out_path];
    } | par-each {|| {name: $in.0, addr: $in.1, path: $in.2}} | each {|i|
          log info $'deploying ($i.path)(char newline)-> ($i.name) | ($i.addr)'
          ssh -t $'ssh://($i.addr)' $'sudo ($i.path)/bin/switch-to-configuration ($mode)'
        }
  }
}

const age_pub = "/run/agenix/age"


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
