# https://github.com/NixOS/nixpkgs/pull/165954

{ stdenvNoCC, stdenv
, lib
, buildFHSUserEnv
, parsecDrv ? null
, dpkg, autoPatchelfHook, makeWrapper
, fetchurl
, alsaLib, openssl, udev
, libglvnd
, libX11, libXcursor, libXi, libXrandr
, libpulseaudio
, libva
, ffmpeg
}:

stdenvNoCC.mkDerivation {
  pname = "parsec-bin";
  version = "150_28";

  src = fetchurl {
    url = "https://builds.parsecgaming.com/package/parsec-linux.deb";
    sha256 = "1hfdzjd8qiksv336m4s4ban004vhv00cv2j461gc6zrp37s0fwhc";
  };

  unpackPhase = ''
    dpkg-deb -x $src .
  '';

  nativeBuildInputs = [ dpkg autoPatchelfHook makeWrapper ];

  buildInputs = [
    stdenv.cc.cc # libstdc++
    libglvnd
    libX11
  ];

  runtimeDependenciesPath = lib.makeLibraryPath [
    stdenv.cc.cc
    libglvnd
    openssl
    udev
    alsaLib
    libpulseaudio
    libva
    ffmpeg
    libX11
    libXcursor
    libXi
    libXrandr
  ];

  prepareParsec = ''
    if [[ ! -e ~/.parsec ]]; then
      cp -r --no-preserve=mode,ownership,timestamps ${placeholder "out"}/share/parsec/skel ~/.parsec
    fi
  '';

  installPhase = ''
    mkdir $out
    mv usr/* $out

    wrapProgram $out/bin/parsecd \
      --prefix LD_LIBRARY_PATH : "$runtimeDependenciesPath" \
      --run "$prepareParsec" \
  '';

  meta = with lib; {
    homepage = "https://parsecgaming.com/";
    description = "Remote streaming service client";
    license = licenses.unfree;
    maintainers = with maintainers; [ arcnmx ];
    platforms = platforms.linux;
    mainProgram = "parsecd";
  };
  passthru = {
    ci.cache.wrap = true;
  };
}
