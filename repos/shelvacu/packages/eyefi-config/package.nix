{
  lib,
  fetchFromGitHub,
  stdenv,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "eyefi-config";
  version = "0-unstable-2025-04-08";

  src = fetchFromGitHub {
    owner = "hansendc";
    repo = "eyefi-config";
    rev = "3f0d0a5433442eadaefd067da42e501089463395";
    hash = "sha256-vLl+WyU1v6y84w/rvqWh1xBoBMNGPc0+LvGAbIqPin0=";
  };

  patches = [ ./fix-open-call.patch ];

  installPhase = ''
    mkdir -p $out/bin
    cp eyefi-config $out/bin/eyefi-config
  '';

  meta = {
    description = "CLI tool for configuring Eye-Fi brand SD cards";
    homepage = "https://github.com/hansendc/eyefi-config";
    license = lib.licenses.gpl2Only;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
    mainProgram = "eyefi-config";
  };
})
