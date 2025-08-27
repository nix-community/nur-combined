{ lib, stdenv, fetchFromGitHub
, nodejs, python3, ninja, writeShellScript
}:

stdenv.mkDerivation rec {
  pname = "ueforth";
  ## https://github.com/flagxor/ueforth/commit/8e46c227aca17f4d0d0eb5ab71af6c88298e35cd
  version = "7.0.7.21";
  src = fetchFromGitHub {
    owner = "flagxor";
    repo = "eforth";
    rev = "19593ee4ad4274a76f9dbee369da87a557c90382";
    sha256 = "sha256-O2xsmZ8p5no4UpOTkhE90UdFx7MTv0kTeb465z5fMPM=";
  };

  nativeBuildInputs = [
    python3 ninja nodejs
  ];

  postPatch = ''
    patchShebangs .
    mkdir -p out/gen
    echo '${src.rev}' > out/gen/REVISION
    echo '${builtins.substring 0 6 src.rev}' > out/gen/REVSHORT
    ln -sf ${writeShellScript "true" ""} tools/revstamp.py
    sed -i "s/'-ffreestanding',//" configure.py
  '';

  buildPhase = ''
    ./configure.py
    ninja posix
  '';

  installPhase = ''
    mkdir -p $out/bin $out/share/ueforth
    cp out/posix/ueforth $out/bin
    cp -R common posix $out/share/ueforth/
  '';

  meta = {
    description = "µEforth, an EForth inspired Forth bootstraped from a minimalist C kernel";
    homepage = "https://github.com/flagxor/eforth/tree/main/ueforth";
    license = lib.licenses.asl20;
    platforms = lib.platforms.all;
  };

}
