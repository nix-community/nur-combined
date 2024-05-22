_:
let
  meta = import ../helpers/meta.nix;
in
{
  nix.settings.substituters = [ meta.atticUrl ];
  nix.settings.trusted-public-keys = [ meta.atticPublicKey ];
}
