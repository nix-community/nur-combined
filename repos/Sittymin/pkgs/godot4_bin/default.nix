{ stdenv
, fetchurl
, unzip
, autoPatchelfHook
, makeWrapper
, lib
, fontconfig
, udev
, libX11
, libGL
, libxkbcommon
, wayland
, libdecor
, speechd
, dbus
, alsa-lib
, libpulseaudio
, libXcursor
, vulkan-loader
, ...
}:

let
  godotIcon = fetchurl {
    url = "https://raw.githubusercontent.com/godotengine/godot/master/icon.svg";
    sha256 = "sha256-epEgD5t/13ch698B6p9fm3sSk3zy613mzXQ4k5hewEg=";
  };
in
stdenv.mkDerivation rec {
  pname = "godot";
  version = "4.3-stable";
  src = fetchurl {
    url = "https://github.com/godotengine/godot/releases/download/${version}/Godot_v${version}_linux.x86_64.zip";
    sha256 = "sha256-feVkRLEwsQr4TRnH4M9jz56ZN+5LqUNkw7fdEUJTyiE=";
  };

  nativeBuildInputs = [ unzip autoPatchelfHook makeWrapper ];

  buildInputs = [
    fontconfig
    udev
    libX11
    libGL
    libxkbcommon
    wayland
    libdecor
    speechd
    dbus
    alsa-lib
    libpulseaudio
    libXcursor
    vulkan-loader
  ];

  unpackPhase = ''
    unzip $src
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp Godot_v${version}_linux.x86_64 $out/bin/godot-bin
    chmod +x $out/bin/godot-bin

    makeWrapper $out/bin/godot-bin $out/bin/godot \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath buildInputs}

    mkdir -p $out/share/applications
    cat > $out/share/applications/godot.desktop << EOF
    [Desktop Entry]
    Name=Godot Engine
    Exec=$out/bin/godot
    Icon=godot
    Type=Application
    Categories=Development;IDE;
    EOF

    mkdir -p $out/share/icons/hicolor/scalable/apps
    cp ${godotIcon} $out/share/icons/hicolor/scalable/apps/godot.svg

    runHook postInstall
  '';

  meta = with lib; {
    description = "Free and open source 2D and 3D game engine";
    homepage = "https://godotengine.org/";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "godot";
  };
}
