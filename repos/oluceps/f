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

def "main ps" [
  target: string
  nodes?: list<string> = $hosts
] {
  let drv = {|name| nix eval --raw $'.#nixosConfigurations.($name).config.age.rekey.derivation'}

  let f = {|target_addr, path| nix copy --substitute-on-destination --to $'ssh://($target_addr)' $path -vvv}

  let target_addr = do $get_map $target

  $map |
  par-each { 
  |per|
     let name = $per.name
     if $name in $nodes {

       do $f ($target_addr.addr.0) (do $drv $per.name) 

     }
   }
}

def "main b" [
  builder: string = "hastur"
  nodes?: list<string> = $hosts
] {

  let target_addr = do $get_map $builder

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
  builder: string = "hastur"
  nodes?: list<string> = $hosts
  mode?: string = "switch"
] {

  let builder_addr = do $get_map $builder

  $map |
  par-each { 
  |per|
     let name = $per.name
     if $name in $nodes {
       nixos-rebuild $mode --flake $'.#($name)' --target-host $"ssh://(do $get_map $name)" --build-host $"ssh://($builder_addr)" --use-remote-sudo
     }
   }

}

def main [] { }
