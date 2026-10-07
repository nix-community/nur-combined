{
  lib,
  stdenvNoCC,
  python3,
  dpkg,
  source,
}:

lib.mapAttrs (
  component: hash:
  stdenvNoCC.mkDerivation (finalAttrs: {
    __structuredAttrs = true;
    name = "chatgpt-${component}-src";
    inherit (source) src;

    strictDeps = true;
    dontUnpack = true;
    dontBuild = true;
    dontFixup = true;

    nativeBuildInputs = [
      python3
      dpkg
    ];

    installPhase = ''
      runHook preInstall

      python3 ${./components.py} extract "$src" components \
        --component ${lib.escapeShellArg component} \
        --dpkg-deb ${dpkg}/bin/dpkg-deb
      mv components/${lib.escapeShellArg component} "$out"

      runHook postInstall
    '';

    outputHashMode = "recursive";
    outputHashAlgo = "sha256";
    outputHash = hash;
  })
) source.componentHashes
