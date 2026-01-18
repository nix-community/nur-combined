{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation rec {
  pname = "rofs-dumper";
  version = "1.0";

  src = fetchFromGitHub {
    owner = "PabloMK7";
    repo = "rofs_dumper";
    rev = "v${version}";
    hash = "sha256-Y8pKQoDnqHHmE3ywBGucnnFW8J0rLhKRKN3rPRbUIww=";
  };

  buildPhase = ''
    ${stdenv.cc.targetPrefix}c++ -std=c++20 main.cpp -o rofs_dump ${lib.optionalString stdenv.hostPlatform.isDarwin "-mmacosx-version-min=13.3"}
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp rofs_dump${stdenv.hostPlatform.extensions.executable} $out/bin
  '';

  meta = with lib; {
    description = "Dumps 3DS ROFS containers (early format of romfs)";
    homepage = "https://github.com/PabloMK7/rofs_dumper";
    license = licenses.unlicense;
    platforms = platforms.all;
    mainProgram = "rofs_dump";
  };
}
