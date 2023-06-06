{ stdenv
, lib
, fetchurl
, autoPatchelfHook
, makeWrapper
, callPackage
, soundfont-fluid
, SDL_compat
, libGL
, glew
, bzip2
, zlib
, libjpeg
, fluidsynth
, fmodex
, openssl
, gtk2
, game-music-emu
}:

let
  fmod = fmodex; # fmodex is on nixpkgs now
  sqlite = callPackage ./sqlite.nix { };
  clientLibPath = lib.makeLibraryPath [ fluidsynth ];
  olibjpeg = (libjpeg.override { enableJpeg8 = true; });

in
stdenv.mkDerivation rec {
  pname = "zandronum-dev-bin";
  version = "3.2-221030-0316";

  src = fetchurl {
    url = "https://zandronum.com/downloads/testing/3.2/ZandroDev3.2-221030-0316linux-x86_64.tar.bz2";
    sha256 = "1fr27yka9jvnc0rzgf2yf4wn3m15l26d48yq966fj37gq0dmrsli";
  };

  # Work around the "unpacker appears to have produced no directories"
  # case that happens when the archive doesn't have a subdirectory.
  setSourceRoot = "sourceRoot=`pwd`";

  # I have no idea why would SDL and libjpeg be needed for the server part!
  # But they are.
  buildInputs = [ openssl bzip2 zlib SDL_compat olibjpeg sqlite game-music-emu libGL glew fmod fluidsynth gtk2 ];

  nativeBuildInputs = [ autoPatchelfHook makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/lib/zandronum
    cp * \
       $out/lib/zandronum
    rm $out/lib/zandronum/env-vars
    makeWrapper $out/lib/zandronum/zandronum-server $out/bin/zandronum-dev-server
    makeWrapper $out/lib/zandronum/zandronum $out/bin/zandronum-dev
    wrapProgram $out/bin/zandronum-dev-server \
      --set LC_ALL=""
    wrapProgram $out/bin/zandronum-dev \
      --set LC_ALL=C
  '';

  postFixup = ''
    patchelf --replace-needed libjpeg.so.8 libjpeg.so \
      --set-rpath $(patchelf --print-rpath $out/lib/zandronum/zandronum):$out/lib/zandronum:${clientLibPath} \
      $out/lib/zandronum/{zandronum,zandronum-server}
  '';

  passthru = {
    inherit fmod sqlite;
  };

  meta = with lib; {
    homepage = "https://zandronum.com/";
    description = "Multiplayer oriented port, based off Skulltag, for Doom and Doom II by id Software";
    license = licenses.unfreeRedistributable;
    platforms = platforms.linux;
  };
}
