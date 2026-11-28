{
  stdenv,
  fetchurl,
  fetchzip,
  bison,
  flex,
  writeTextFile,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "spass";
  version = "3.8ds";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchzip {
    url = "https://www.cs.vu.nl/~jbe248/spass-${finalAttrs.version}-src.tar.gz";
    hash = "sha256-DqDNNyMwDXznrUpgP6iZ6qwcHXiP1wHsmp+zken7EmU=";
  };

  patches = [
    (fetchurl {
      url = "https://raw.githubusercontent.com/sempiternal-aurora/nixpkgs/30b07b7e68d352cc26eb51d6b2cf402845b16e77/pkgs/by-name/is/isabelleComponents/spass/fix-gcc15-compile.patch";
      hash = "sha256-a4TM1D5qN1J29fz5o8QP1MgfVoU6gLkBrza2KFnFfnA=";
    })
  ];

  nativeBuildInputs = [
    bison
    flex
  ];

  buildFlags = [
    "RM=\"rm -f\""
    "SPASS"
    "CC=${stdenv.cc.targetPrefix}cc"
  ];

  installPhase = ''
    runHook preInstall

    install -Dm0755 SPASS $out/bin/SPASS

    runHook postInstall
  '';

  passthru.settings = writeTextFile {
    name = "spass-settings";
    text = ''
      SPASS_HOME="${finalAttrs.finalPackage}/bin"
      SPASS_VERSION="${finalAttrs.version}"
    '';
    destination = "/etc/settings";
  };
})
