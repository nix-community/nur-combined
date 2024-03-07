#!/usr/bin/env nu

const map = [
    [name, addr];
		[hastur, riro@10.0.2.2],
		[kaambl, elen@localhost],
		[eihort, elen@10.0.2.6],
		[nodens, dgs],
		# [azasos, tcs],
		# [abhoth, abh],
		[colour, col],
]

const hosts = $map.name

let get_map = { |per| $map | where name == $per }

let get_addr = { |b| do $get_map $b | $in.addr.0 }

def "main p" [
  target: string
  node?: string
] {
  let drv = { |name| nix eval --raw $'.#nixosConfigurations.($name).config.age.rekey.derivation' }

  let push = { |t_addr, path| nix copy --substitute-on-destination --to $'ssh://($t_addr)' $path -vvv }

  let target_addr = do $get_addr $target

  do $push ($target_addr) (do $drv $node) 
}

def "main b" [
  node?: string
  --builder (-b): string = "hastur"
] {

  let target_addr = do $get_addr $builder

  nom build $'.#nixosConfigurations.($node).config.system.build.toplevel' --builders $"($target_addr)"

}

def "main d" [
  node?: string
  mode?: string = "switch"
  --builder (-b): string = "hastur"
] {

  let builder_addr = do $get_addr $builder

  nixos-rebuild $mode --flake $'.#($node)' --target-host (do $get_addr $node) --build-host $"($builder_addr)" --use-remote-sudo

}

const age_pub = /run/agenix/age

def "main en" [name: string] {
  rage -e $name -i $age_pub -i ./sec/age-yubikey-identity-7d5d5540.txt.pub -o $'./($name).age'
  srm $name
}

def "main de" [name: string] {
  rage -d $'./($name)' -i $age_pub # -i ./age-yubikey-identity-7d5d5540.txt.pub
}

def "main dump" [] {
  srm -frC ./sec/decrypted
  mkdir ./sec/decrypted
  ls ./sec/*.age | par-each {|i| main de $i.name | save $'sec/decrypted/($i.name | path basename)' }
}

def "main chk" [] {
  let allow = ["f" "age-yubikey-identity-7d5d5540.txt.pub" "rekeyed"]
  ls sec | filter {|i| not ($in.name | path basename | str ends-with "age")} | filter {|i| not ($i.name | path basename | $in in $allow) }
}

def main [] { }
