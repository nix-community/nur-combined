#!/usr/bin/env nu

const map_path = "/run/agenix/addr-map"

export-env {
  $env.get_addr = { |map, per| $map | where name == $per | $in.addr.0 }
}

export def br [
  nodes?: list<string>
  --builder (-b): string = "hastur"
] {

  let map = (open $map_path | lines | split column ":" name addr)

  let target_addr = do $env.get_addr ($map) $builder

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

export def b [
  nodes?: list<string>
] {

  $nodes | par-each {|| 
    (nix build $'.#nixosConfigurations.($in).config.system.build.toplevel') 
  }

}

export def d [
  nodes?: list<string>
  mode?: string = "switch"
  --builder (-b): string = "hastur"
] {

  let map = (open $map_path | lines | split column ":" name addr)

  let get_addr = {|x| do $env.get_addr ($map) ($x)}

  let builder_addr = do $get_addr $builder

  $nodes | par-each {||
    (nixos-rebuild $mode
      --flake $'.#($in)'
      --target-host (do $get_addr $in)
      --build-host $"($builder_addr)"
      --use-remote-sudo)
  }

}

const age_pub = /run/agenix/age


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
