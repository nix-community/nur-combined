{
  clangStdenv,
  lib,
  rustc,

  fetchFromGitHub,
  nix-update-script,
  makeWrapper,
  writeShellScriptBin,

  pkgsCross,
  wineWow64Packages,
  qemu_full,
  fasm,
  uxn,
  mono,

  windowsSupport ? false,
  aarch64Support ? false,
  monoSupport ? false,
}:
let
  isAarch64 = clangStdenv.hostPlatform.system == "aarch64-linux";
  runtimeDeps = [
    fasm
    uxn
  ]
  ++ lib.optionals (!isAarch64 && aarch64Support) [
    pkgsCross.aarch64-multiplatform.buildPackages.gcc
    qemu_full
    # double -> triple
    (writeShellScriptBin "aarch64-linux-gnu-as" "aarch64-unknown-linux-gnu-as $@")
    (writeShellScriptBin "aarch64-linux-gnu-gcc" "aarch64-unknown-linux-gnu-gcc $@")
  ]
  ++ lib.optionals windowsSupport [
    pkgsCross.mingwW64.buildPackages.gcc
    wineWow64Packages.minimal
  ]
  ++ lib.optionals monoSupport [ mono ];
in
clangStdenv.mkDerivation {
  # TODO: when Tsoding starts building with nob, use buildNobPackage
  pname = "b";
  version = "0-unstable-2025-08-22";

  src = fetchFromGitHub {
    owner = "bext-lang";
    repo = "b";
    rev = "5d23941d6c41a3fc8fc8c1589780ab086a86c414";
    hash = "sha256-eOsCcEaIYR83gE5wRVkvveRtMxdbs/9/c1yaWXM+uxU=";
  };

  nativeBuildInputs = [
    rustc
    makeWrapper
  ];

  doCheck = true;
  nativeCheckInputs = runtimeDeps;

  preCheck = lib.optionalString windowsSupport ''
    export WINEPREFIX="$(pwd)/.wine"
    mkdir -p $WINEPREFIX
  '';

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
    homepage = "https://github.com/bext-lang/b";
    license = lib.licenses.mit;
    mainProgram = "b";
  };
}
