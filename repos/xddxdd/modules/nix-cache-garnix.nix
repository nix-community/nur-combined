_:
let
  meta = import ../helpers/meta.nix;
in
{
  key = "xddxdd-nur-packages-nix-cache-attic";
  config = {
    nix.settings.substituters = [ meta.garnixUrl ];
    nix.settings.trusted-substituters = [ meta.garnixUrl ];
    nix.settings.trusted-public-keys = [ meta.garnixPublicKey ];
  };
}
