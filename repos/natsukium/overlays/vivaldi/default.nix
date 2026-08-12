final: prev:
let
  meta = prev.vivaldi.meta // {
    description = "A Browser for our Friends powerful and personal";
    platforms = prev.vivaldi.meta.platforms ++ prev.lib.platforms.darwin;
  };
in
{
  vivaldi =
    if prev.stdenv.hostPlatform.isLinux then
      prev.vivaldi.overrideAttrs (_: {
        inherit meta;
      })
    else
      let
        source =
          (import ../../_sources/generated.nix {
            inherit (prev)
              fetchgit
              fetchurl
              fetchFromGitHub
              dockerTools
              ;
          }).vivaldi-darwin;
      in
      prev.stdenvNoCC.mkDerivation {
        pname = "vivaldi";
        inherit (source) version src;

        preferLocalBuild = true;

        nativeBuildInputs = [ prev.undmg ];

        sourceRoot = "Vivaldi.app";

        installPhase = ''
          runHook preInstall

          mkdir -p $out/Applications/Vivaldi.app
          cp -R . $out/Applications/Vivaldi.app

          runHook postInstall
        '';

        inherit meta;
      };
}
