{
  clangStdenv,
  lib,
  replaceVars,
  fetchFromGitHub,
  rustc,
  fasm,
  nob_h,
  nix-update-script,
  makeWrapper,
}:
clangStdenv.mkDerivation {
  # TODO: when Tsoding starts building with nob, use buildNobPackage
  pname = "b";
  version = "0-unstable-2025-05-26";

  src = fetchFromGitHub {
    owner = "tsoding";
    repo = "b";
    rev = "cbe341c184c378cc888cc313b0ef984ce31b821e";
    hash = "sha256-e1OGgVAyYLdZP4IIz3Y+Ir+mO5caclYciISP/ARorcU=";
  };

  patches = [
    (replaceVars ./use-nix-nob.patch {
      NOB_H = "${nob_h}/include/nob.h";
    })
  ];

  postPatch = "rm thirdparty/nob.h";

  nativeBuildInputs = [
    rustc
    makeWrapper
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp build/b $out/bin
    install -Dm444 examples/*.b -t $out/opt/b

    wrapProgram $out/bin/b \
      --prefix PATH : "${lib.makeBinPath [ fasm ]}"

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Compiler for the B Programming Language implemented in Crust";
    homepage = "https://github.com/tsoding/b";
    license = lib.licenses.mit;
    mainProgram = "b";
  };
}
