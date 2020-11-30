nur: self: super:
{
   zoom-us = super.zoom-us.overrideAttrs (oldAttrs: rec {
     runtimeDependencies = oldAttrs.runtimeDependencies ++ [ super.alsaLib ];
   });
}
