{ lib }:
let
  mkColorOption = with lib; {default ? "#000000", description ? "" }: mkOption {
    inherit description default;
    example = "#abcdef";
    type = types.strMatching "#[0-9a-f]{6}";
  };
in
mkColorOption
