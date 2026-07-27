_: _:
let
  unstable = (import ../.).pkgs-unstable { };
in
{
  inherit (unstable)
    # cachix
    #git
    ;
}
