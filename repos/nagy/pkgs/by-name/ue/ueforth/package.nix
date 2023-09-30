{ stdenv, lib, python3, fetchFromGitHub, nodejs, git, zip }:

stdenv.mkDerivation rec {
  pname = "ueforth";
  version = "unstable-2023-07-08";

  src = fetchFromGitHub {
    owner = "flagxor";
    repo = "ueforth";
    rev = "564a8fc68b545ebeb3abab34548bfcf5591c611c";
    hash = "sha256-N+7aHMAHbLE8R6qAr5Tiz7AY7+T9Fcx/onz0adt6tbA=";
  };

  makeFlags = [
    "TARGETS:=esp32_target"
    "NODEJS:=${lib.getExe nodejs}"
    "REVISION:=${src.rev}"
  ];

  postPatch = ''
    substituteInPlace {web,tools}/*.js \
      --replace "/usr/bin/env nodejs" "/usr/bin/env node"
    patchShebangs {web,tools}/*.js tools/memuse.py
  '';

  nativeBuildInputs =
    [ (python3.withPackages (p: [ p.pyserial ])) nodejs git zip ];

  checkTarget = "tests";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/
    mv out/esp32 $out/share/ueforth
    rm $out/share/ueforth/ESP32forth.zip

    runHook postInstall
  '';

  meta = with lib; {
    description =
      "This EForth inspired implementation of Forth is bootstraped from a minimalist C kernel";
    homepage = "https://esp32forth.appspot.com/ESP32forth.html";
    license = licenses.asl20;
    maintainers = with maintainers; [ nagy ];
  };
}
