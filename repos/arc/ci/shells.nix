{ arc }:
let
  shells = with arc.shells.rust; [ stable nightly ];
in
map (s: s.shellEnv) shells
