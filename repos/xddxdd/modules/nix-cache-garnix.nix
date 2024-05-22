_:
let
  meta = import ../helpers/meta.nix;
in
{
  nix.settings.substituters = [ meta.garnixUrl ];
  nix.settings.trusted-public-keys = [ meta.garnixPublicKey ];
}
