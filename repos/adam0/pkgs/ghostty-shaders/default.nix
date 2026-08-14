{
  # keep-sorted start
  callPackage,
  lib,
  stdenvNoCC,
  # keep-sorted end
}: let
  inherit (lib) mapAttrs recurseIntoAttrs;

  mkShaderArgs = {
    # keep-sorted start
    homepage,
    name,
    shaderFile,
    src,
    version,
    # keep-sorted end
  }: {
    pname = "ghostty-shader-${name}";
    inherit version;

    inherit src;

    installPhase = ''
      runHook preInstall

      mkdir -p "$out"
      cp ${shaderFile} "$out/${shaderFile}"

      runHook postInstall
    '';

    dontBuild = true;

    passthru = {inherit shaderFile;};

    meta = {
      # keep-sorted start
      description = "${name} cursor shader for Ghostty";
      inherit homepage;
      license = lib.licenses.mit;
      platforms = lib.platforms.all;
      # keep-sorted end
    };
  };

  mkShaders = {
    # keep-sorted start
    homepage,
    shaders,
    src,
    version,
    # keep-sorted end
  }:
    recurseIntoAttrs (mapAttrs (name: shaderFile:
      stdenvNoCC.mkDerivation (mkShaderArgs {
        inherit
          # keep-sorted start
          homepage
          name
          shaderFile
          src
          version
          # keep-sorted end
          ;
      }))
    shaders);
in {
  # keep-sorted start
  hced = callPackage ./hced.nix {inherit mkShaders;};
  sahaj = callPackage ./sahaj.nix {inherit mkShaders;};
  # keep-sorted end
}
