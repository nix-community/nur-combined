{
  pkgs ? import <nixpkgs> { },
}:

pkgs.callPackage (
  {
    stdenv,
    lib,
    pari,
  }:

  let
    pari-patched = pari.overrideAttrs (oldAttrs: {
      patches = oldAttrs.patches or [ ] ++ [ ./pari.patch ];
    });
  in

  stdenv.mkDerivation {
    pname = "massey-pari";
    version = "0-unstable-git";

    src = ./.;

    postPatch = lib.optionalString stdenv.hostPlatform.isLinux /* sh */ ''
      substituteInPlace Makefile \
        --replace-fail '-flto=thin' '-flto' \
        --replace-fail 'CC =' '# CC ='
    '';

    buildInputs = [
      pari-patched
    ];

    doCheck = true;

    checkPhase = ''
      runHook preCheck
      ./build/massey 2 's^2 + 5' # Help I don't know number theory.
      runHook postCheck
    '';

    installPhase = ''
      runHook preInstall
      install -Dm755 build/massey $out/bin/massey
      runHook postInstall
    '';

    meta = {
      description = "Compute Massey products in étale cohomology of the ring of integers of a number field, plus some more";
      license = lib.licenses.mit;
      homepage = "https://github.com/ericahlqvist/Massey-pari";
      mainProgram = "massey";
    };
  }
) { }
