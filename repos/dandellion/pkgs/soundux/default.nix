{
  lib, stdenv, fetchFromGitHub, cmake, ninja, pkg-config, makeWrapper, wrapGAppsHook, makeDesktopItem, copyDesktopItems,
  libappindicator-gtk3, openssl, pipewire, pulseaudio, webkitgtk, xorg,
  libpulseaudio, libwnck3,
  downloaderSupport ? true, ffmpeg, youtube-dl
}:

let
  downloaderPath = lib.makeBinPath [ffmpeg youtube-dl ];
in
stdenv.mkDerivation rec {
  pname = "soundux";
  version = "0.2.7";

  src = fetchFromGitHub {
    owner = "Soundux";
    repo = "Soundux";
    rev = "0.2.7";
    fetchSubmodules = true;
    sha256 = "15kd9vl7inn8zm5cqzjkb6zb9xk2xxwpkm7fx1za3dy9m61sq839";
  };

  cmakeFlags = [ "-DCMAKE_BUILD_TYPE=Release" ];

  dontWrapGApps = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt $out/bin
    cp -r dist soundux-${version} $out/opt

    runHook postInstall
  '';

  # Soundux loads pipewire, pulse and libwnck optionally during runtime
  postFixup = ''
    makeWrapper $out/opt/soundux-${version} $out/bin/soundux \
      --prefix LD_LIBRARY_PATH ":" ${lib.makeLibraryPath [libpulseaudio pipewire libwnck3 ]} \
      "''${gappsWrapperArgs[@]}" \
      ${lib.optionalString downloaderSupport "--prefix PATH \":\" " + downloaderPath}
  '';

  nativeBuildInputs = [ cmake ninja pkg-config makeWrapper wrapGAppsHook copyDesktopItems ];

  buildInputs = [
    libappindicator-gtk3
    openssl
    pipewire
    pulseaudio
    webkitgtk
    xorg.libX11
    xorg.libXtst
  ];

  desktopItems = makeDesktopItem {
    name = "Soundux";
    exec = pname;
    desktopName = "Soundux";
    genericName = "Soundboard";
    categories = "Audio;Music;Player;AudioVideo;";
    comment = "A universal soundboard that uses PulseAudio modules or PipeWire linking";
  };

  meta = with lib; {
    homepage = "https://soundux.rocks/";
    description = "cross-platform soundboard";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
    maintainers = with maintainers; [ dandellion ];
  };
}


