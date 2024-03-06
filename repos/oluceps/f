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

let get_map = { |per| $map | filter {|i| $i.name == $per } }

let get_addr = { |b| do $get_map $b | $in.addr.0 }

def "main p" [
  target: string
  nodes?: list<string> = $hosts
] {
  let drv = { |name| nix eval --raw $'.#nixosConfigurations.($name).config.age.rekey.derivation' }

  let push = { |t_addr, path| nix copy --substitute-on-destination --to $'ssh://($t_addr)' $path -vvv }

  let target_addr = do $get_addr $target

  $map |
  par-each { 
  |per|
     let name = $per.name
     if $name in $nodes {

       do $push ($target_addr) (do $drv $per.name) 

     }
   }
}

def "main b" [
  nodes?: list<string> = $hosts
  --builder (-b): string = "hastur"
] {

  let target_addr = do $get_addr $builder

  $map |
  par-each { 
  |per|
     let name = $per.name
     if $name in $nodes {
       nom build $'.#nixosConfigurations.($name).config.system.build.toplevel' --builders $"($target_addr)"
     }
   }

}

def "main d" [
  nodes?: list<string> = $hosts
  mode?: string = "switch"
  --builder (-b): string = "hastur"
] {

  let builder_addr = do $get_addr $builder

  $map |
  par-each {
  |per|
     let name = $per.name
     if $name in $nodes {
       nixos-rebuild $mode --flake $'.#($name)' --target-host (do $get_addr $name) --build-host $"($builder_addr)" --use-remote-sudo
     }
   }

}

def "main en" [name: string] {
  rage -e $name -i /run/agenix/age -i ./age-yubikey-identity-7d5d5540.txt.pub -o $'./($name).age'
  srm $name
}

def "main de" [name: string] {
  rage -d $'./($name)' -i /run/agenix/age # -i ./age-yubikey-identity-7d5d5540.txt.pub
}

def "main dump" [] {
  srm -frC decrypted
  mkdir decrypted
  ls ./*.age | par-each {|i| main de $i.name | save $'decrypted/($i.name)' }
}

def "main chk" [] {
  let allow = ["f" "age-yubikey-identity-7d5d5540.txt.pub"]
  ls | filter {|i| not ($in.name | str ends-with "age")} | filter {|i| not ($i.name in $allow) }
}

def main [] { }
