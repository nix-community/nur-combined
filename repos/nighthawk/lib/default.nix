{ pkgs }:

with pkgs.lib;
{
  mkSimpleLinks =
    { name, links }:
    pkgs.stdenvNoCC.mkDerivation {
      inherit name;
      preferLocalBuild = true;

      dontUnpack = true;
      dontPatch = true;
      dontUpdateAutotoolsGnuConfigScripts = true;
      dontConfigure = true;
      dontBuild = true;
      dontFixup = true;

      installPhase = ''
        mkdir $out
      ''
      + concatStringsSep "\n" (
        mapAttrsToList (k: v: "ln -s ${info "evaluating ${k}" v} $out/${k}") links
      );
    };
}
