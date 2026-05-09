{
  # keep-sorted start
  callPackage,
  fetchFromGitHub,
  lib,
  stdenvNoCC,
  # keep-sorted end
}: let
  inherit
    (builtins)
    # keep-sorted start
    mapAttrs
    readDir
    # keep-sorted end
    ;
  inherit
    (lib)
    # keep-sorted start
    filterAttrs
    hasSuffix
    mapAttrs'
    nameValuePair
    pipe
    removeSuffix
    # keep-sorted end
    ;

  root = ./shaders;

  mkGhosttyCursorShader = {
    # keep-sorted start
    description,
    meta ? {},
    pname,
    shaderFile,
    version,
    # keep-sorted end
  }:
    stdenvNoCC.mkDerivation {
      inherit pname version;

      src = fetchFromGitHub {
        owner = "sahaj-b";
        repo = "ghostty-cursor-shaders";
        rev = "06d4e90fb5410e9c4d0b3131584060adddf89406";
        hash = "sha256-G/UIr1bKnxn1AcHl/4FL/jou6b7M2VeREslYVELxdmw=";
      };

      dontBuild = true;

      installPhase = ''
        runHook preInstall

        install -Dm644 ${shaderFile} "$out/${shaderFile}"

        runHook postInstall
      '';

      meta =
        meta
        // {
          # keep-sorted start
          inherit description;
          homepage = "https://github.com/sahaj-b/ghostty-cursor-shaders";
          license = lib.licenses.mit;
          mainProgram = shaderFile;
          platforms = lib.platforms.all;
          # keep-sorted end
        };
    };

  call = name: callPackage (root + "/${name}") {inherit mkGhosttyCursorShader;};
in
  {
    inherit mkGhosttyCursorShader;
  }
  // pipe root [
    readDir
    (filterAttrs (name: type: type == "regular" && hasSuffix ".nix" name))
    (mapAttrs' (name: _: nameValuePair (removeSuffix ".nix" name) (call name)))
  ]
