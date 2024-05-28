_:
let
  meta = import ../helpers/meta.nix;
in
{
  nix.settings.substituters = [ meta.cachixUrl ];
  nix.settings.trusted-substituters = [ meta.cachixUrl ];
  nix.settings.trusted-public-keys = [ meta.cachixPublicKey ];
}
