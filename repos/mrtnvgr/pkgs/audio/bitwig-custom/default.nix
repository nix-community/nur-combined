{
  fetchurl,
  lib,
  openjdk,
  callPackage,

  bitwig-studio5-unwrapped,
  unwrappedPkg  ? bitwig-studio5-unwrapped,

  customSrc     ? null, # version, hash
  customJar     ? null,
  theme         ? null,
}:
let
  unwrapped =
    unwrappedPkg.overrideAttrs (oldAttrs:
    let
      bitwigVersion = if (customSrc != null) then customSrc.version else oldAttrs.version;
      bitwigHash = if (customSrc != null) then customSrc.hash else oldAttrs.src.outputHash;

      bitwig-theme-editor = fetchurl {
        url = "https://github.com/Berikai/bitwig-theme-editor/releases/download/1.4.3/bitwig-theme-editor-1.4.3.jar";
        hash = "sha256-TvYvPPjT/qlYFxgGyxEaDXrjNtaWfppFqgArjSQuunw=";
      };
    in {
      version = "${bitwigVersion}-patched";
      src = fetchurl {
        name = "bitwig-studio-${bitwigVersion}.deb";
        url = "https://www.bitwig.com/dl/Bitwig%20Studio/${bitwigVersion}/installer_linux/";
        hash = bitwigHash;
      };

      preInstall = ''
        ${lib.optionalString (customJar != null) ''
          cp ${customJar} opt/bitwig-studio/bin/bitwig.jar
        ''}

        ${lib.optionalString (theme != null) ''
          ${openjdk}/bin/java -jar ${bitwig-theme-editor} opt/bitwig-studio/bin/bitwig.jar apply ${theme}
        ''}
      '';
    });
in
  callPackage ./bitwig-wrapper.nix { bitwig-studio-unwrapped = unwrapped; }
