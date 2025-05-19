_:
let
  meta = import ../helpers/meta.nix;
in
{
  key = "xddxdd-nur-packages-nix-cache-attic";
  config = {
    nix.settings.substituters = [ meta.atticUrl ];
    nix.settings.trusted-substituters = [ meta.atticUrl ];
    nix.settings.trusted-public-keys = [ meta.atticPublicKey ];
  };
}
