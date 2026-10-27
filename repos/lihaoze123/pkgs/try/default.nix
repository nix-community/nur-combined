{ lib, stdenv, fetchFromGitHub, ruby, makeBinaryWrapper }:

stdenv.mkDerivation {
  pname = "try";
  version = "1.10.1";

  src = fetchFromGitHub {
    owner = "tobi";
    repo = "try";
    rev = "be566829856ca6bd22963e38a28ffb5efa24c7de";
    hash = "sha256-b+ev9XQDM/nWKFCuF22gUoT0ozxLTd9/fkazW45+WfM=";
  };
  nativeBuildInputs = [ makeBinaryWrapper ruby ];
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/bin"
    cp try.rb "$out/bin/try"
    cp -r lib "$out/bin/"
    chmod +x "$out/bin/try"
    wrapProgram "$out/bin/try" --prefix PATH : ${ruby}/bin
    patchShebangs "$out/bin/.try-wrapped"
    runHook postInstall
  '';

  meta = {
    description = "Fresh directories for every vibe (tobi/try)";
    homepage = "https://github.com/tobi/try";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    mainProgram = "try";
  };
}
