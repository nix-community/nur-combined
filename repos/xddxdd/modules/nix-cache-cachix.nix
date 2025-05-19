_:
let
  meta = import ../helpers/meta.nix;
in
{
  key = "xddxdd-nur-packages-nix-cache-attic";
  config = {
    nix.settings.substituters = [ meta.cachixUrl ];
    nix.settings.trusted-substituters = [ meta.cachixUrl ];
    nix.settings.trusted-public-keys = [ meta.cachixPublicKey ];
  };
}
