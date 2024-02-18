inputs:
let inherit (import ./lib.nix inputs) data; in
([
  ./hastur
  ./kaambl
]
++ map (x: ./. + x) (map (x: "/" + x) data.withoutHeads)
)
++ [
  ./livecd
  ./bootstrap /* tested on: `azure v2 vm` */
]
