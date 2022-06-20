{
  pkgs,
  lib,
  characterVariants ? ["dv1" "ij1" "ll2"],
}: let
  inherit (lib) concat mergeAttrs optionalString;
in
  pkgs.terminus_font.overrideAttrs (old: {
    patches = concat (old.patches or []) (
      map (variant: "alt/${variant}.diff") characterVariants
    );

    meta = mergeAttrs old.meta {
      description =
        (old.meta.description or "")
        + optionalString (characterVariants != []) " (customized version)";

      longDescription =
        (old.meta.longDescription or "")
        + optionalString (characterVariants != []) ''

          This package is customized to use several non-default character variants
          (enabled patches: ${toString characterVariants}).
        '';
    };
  })
