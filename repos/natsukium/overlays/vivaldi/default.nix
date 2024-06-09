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
        undmg' = prev.undmg.overrideAttrs (oldAttrs: {
          patches = (oldAttrs.patches or [ ]) ++ [
            (prev.fetchpatch {
              # https://github.com/matthewbauer/undmg/pull/11
              name = "support-lzma patch";
              url = "https://github.com/matthewbauer/undmg/commit/bc134e3f8d03b43a17e986d8164d583b50535ace.patch";
              hash = "sha256-WsW8QU4dt43GHe2E/HzbHb6VSa7JGupn//f4PeIonxQ=";
            })
          ];
          buildInputs = oldAttrs.buildInputs ++ [ prev.lzma ];
        });
      in
      prev.stdenvNoCC.mkDerivation {
        pname = "vivaldi";
        inherit (source) version src;

        preferLocalBuild = true;

        nativeBuildInputs = [ undmg' ];

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
