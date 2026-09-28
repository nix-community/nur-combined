final: prev:
let
  buildGoApplication' =
    rattrs:
    (final.gomod2nix.buildGoApplication (prev.lib.fix (prev.lib.toFunction rattrs)))
    // {
      extend =
        overlay:
        buildGoApplication' (
          prev.lib.fix (prev.lib.extends (prev.lib.toExtension overlay) (prev.lib.toFunction rattrs))
        );
    };
in
{
  inherit buildGoApplication';
  gomod2nix = prev.gomod2nix.overrideAttrs (prevAttrs: {
    meta.platforms = prev.lib.platforms.all;
    patches = (prevAttrs.patches or [ ]) ++ [
      ./nix-eval-impure.patch
    ];
  });
}
