final: prev:
let
  meta = prev.copyq.meta // {
    platforms = prev.copyq.meta.platforms ++ [ "aarch64-darwin" ];
  };
in
{
  copyq =
    if prev.stdenv.hostPlatform.isLinux then
      prev.copyq.overrideAttrs (_: {
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
          }).copyq-darwin;
      in
      prev.stdenv.mkDerivation {
        pname = "copyq";
        inherit (source) version src;

        preferLocalBuild = true;

        nativeBuildInputs = [
          prev.undmg
          prev.unzip
        ];

        unpackCmd = ''
          unzip $curSrc
          undmg CopyQ.dmg
        '';

        sourceRoot = "CopyQ.app";

        installPhase = ''
          mkdir -p $out/Applications/CopyQ.app
          cp -R . $out/Applications/CopyQ.app
        '';

        inherit meta;
      };
}
