#!/usr/bin/env nu

const map = [
    [name, addr];
		[hastur, riro@10.0.1.2],
		[kaambl, elen@localhost],
		[eihort, elen@10.0.2.6],
		[nodens, dgs],
		# [azasos, tcs],
		# [abhoth, abh],
		[colour, col],
]

const hosts = $map.name

export-env {
  $env.get_map = { |per| $map | where name == $per }
  $env.get_addr = { |b| do $env.get_map $b | $in.addr.0 }
}

export def b [
  nodes?: list<string>
  --builder (-b): string = "hastur"
] {

  let target_addr = do $env.get_addr $builder

  let h = hostname | str trim

  let job = if $h != $builder {
    ["--max-jobs" "0"]
  }

  let machine_spec = "x86_64-linux - - - big-parallel"

  $nodes | par-each {|| 
    (nix build $'.#nixosConfigurations.($in).config.system.build.toplevel'
      --builders $"($target_addr) ($machine_spec)"
      ...($job) -vvv) 
  }

}

export def d [
  nodes?: list<string>
  mode?: string = "switch"
  --builder (-b): string = "hastur"
] {

  let builder_addr = do $env.get_addr $builder

  $nodes | par-each {||
    (nixos-rebuild $mode
      --flake $'.#($in)'
      --target-host (do $env.get_addr $in)
      --build-host $"($builder_addr)"
      --use-remote-sudo)
  }

}

const age_pub = /run/agenix/age

export def en [name: string] {
  rage -e $name -i $age_pub -i ./sec/age-yubikey-identity-7d5d5540.txt.pub -o $'./($name).age'
  srm $name
}

export def de [name: string] {
  rage -d $'./($name)' -i $age_pub # -i ./age-yubikey-identity-7d5d5540.txt.pub
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
