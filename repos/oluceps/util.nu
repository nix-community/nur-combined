#!/usr/bin/env nu

const map = [
    [name,addr];
    [hastur,riro@10.0.1.2],
    [kaambl,elen@10.0.1.3],
    [abhoth,elen@38.47.119.151],
    [azasos,elen@116.196.112.43],
    [eihort,elen@10.0.1.6],
    [nodens,elen@144.126.208.183]
  ];

export-env {
  $env.get_addr = { |map, per| $map | where name == $per | $in.addr.0 }
  $env.map = $map
}

export def br [
  nodes?: list<string>
  --builder (-b): string = "hastur"
] {

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

# build
export def b [
  nodes?: list<string>
] {

  $nodes | par-each {|| 
    (nom build $'.#nixosConfigurations.($in).config.system.build.toplevel')
  }

}

# deploy
export def d [
  nodes?: list<string>
  mode?: string = "switch"
  --builder (-b): string = "hastur"
] {

  let get_addr = {|x| do $env.get_addr ($map) ($x)}

  let builder_addr = do $get_addr $builder

  if ($nodes == null) {
    (nh os switch .)
  } else {
    $nodes | par-each {||
      (nixos-rebuild $mode
        --flake .#
        --target-host (do $get_addr $in)
        --build-host $builder_addr
        --use-remote-sudo)
    }
  }
}

const age_pub = "/run/agenix/age"


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
