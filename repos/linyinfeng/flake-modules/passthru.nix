{ lib, ... }:

{
  options = {
    passthru = lib.mkOption {
      visible = false;
      type = with lib.types; attrsOf unspecified;
    };
  };
}
