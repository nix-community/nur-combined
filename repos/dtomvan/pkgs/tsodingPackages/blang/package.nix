{
  clangStdenv,
  lib,
  rustc,

  fetchFromGitHub,
  nix-update-script,
  makeWrapper,

  fasm,
  uxn,
  binutils,
}:
let
  runtimeDeps = [
    fasm
    uxn
  ] ++ lib.optionals (clangStdenv.hostPlatform.system == "aarch64-linux") [ binutils ];
in
clangStdenv.mkDerivation {
  # TODO: when Tsoding starts building with nob, use buildNobPackage
  pname = "b";
  version = "0-unstable-2025-06-08";

  src = fetchFromGitHub {
    owner = "tsoding";
    repo = "b";
    rev = "e445d6df27d55d42fb9a67aa73f25088790bdf0a";
    hash = "sha256-zbhxFpcVgbn+f91xmW6Q3DFUUOjbpAA8eAXTuKyZqXo=";
  };

  nativeBuildInputs = [
    rustc
    makeWrapper
  ];

  doCheck = true;
  nativeCheckInputs = runtimeDeps;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/opt/b/
    cp build/b $out/bin
    cp -r examples $out/opt/b

    wrapProgram $out/bin/b \
      --prefix PATH : "${lib.makeBinPath runtimeDeps}"

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
