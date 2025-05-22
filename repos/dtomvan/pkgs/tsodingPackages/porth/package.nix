{
  lib,
  python3,
  stdenv,
  fetchFromGitLab,
  fasm,
  autoPatchelfHook,
  makeWrapper,
  nix-update-script,
}:
stdenv.mkDerivation {
  pname = "porth";
  version = "0-unstable-2022-02-14";

  src = fetchFromGitLab {
    owner = "tsoding";
    repo = "porth";
    rev = "d4095557cca4e76c9031e64537f5ee3a125de975";
    hash = "sha256-kN3czOR/84VCECLQHHTeko+z26QHnezWZGOKgva647E=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    fasm
  ];

  buildPhase = ''
    runHook preBuild
    fasm -m 524288 ./bootstrap/porth-linux-x86_64.fasm
    chmod +x ./bootstrap/porth-linux-x86_64
    ./bootstrap/porth-linux-x86_64 com ./porth.porth
    runHook postBuild
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp porth $out/bin
  '';

  fixupPhase = ''
    wrapProgram $out/bin/porth \
      --prefix PATH ":" ${lib.getExe fasm}
  '';

  doCheck = true;
  checkPhase = "${lib.getExe python3} test.py";

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Concatenative Programming Language for Computers";
    homepage = "https://gitlab.com/tsoding/porth";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "porth";
  };
}
