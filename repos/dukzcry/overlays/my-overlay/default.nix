let overlay1 = self: super:
{
   zoom-us = super.zoom-us.overrideAttrs (oldAttrs: rec {
    runtimeDependencies = oldAttrs.runtimeDependencies ++ [ pkgs.alsaLib ];
   })
};
