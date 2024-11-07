{
  alsa-lib,
  autoPatchelfHook,
  copyDesktopItems,
  freetype,
  lib,
  libjack2,
  librsvg,
  libGL,
  makeDesktopItem,
  makeWrapper,
  p7zip,
  requireFile,
  stdenv,
  xorg,
  zlib,
  archdir ? if (stdenv.hostPlatform.system == "aarch64-linux") then "arm-64bit" else "x86-64bit",
}:
let
  versionForFile = v: builtins.replaceStrings [ "." ] [ "" ] v;
in
stdenv.mkDerivation rec {
  mainProgram = "Pianoteq 8";
  startupWMClass = "Pianoteq";
  pname = "pianoteq";
  version = "8.3.1";

  src = requireFile {
    name = "pianoteq_linux_v${versionForFile version}.7z";
    url = "https://www.modartt.com/pianoteq";
    sha256 = "1cgwv3a32jsr2isxqd1jcnz0ljx37pxw9fcwbh94bsww7jfihw49";
  };

  unpackPhase = ''
    ${p7zip}/bin/7z x $src
  '';

  nativeBuildInputs = [
    autoPatchelfHook
    copyDesktopItems
    makeWrapper
    librsvg
  ];

  buildInputs = [
    stdenv.cc.cc.lib
    xorg.libX11 # libX11.so.6
    xorg.libXext # libXext.so.6
    alsa-lib # libasound.so.2
    freetype # libfreetype.so.6
    libGL # libGL.so.1
  ];

  desktopItems = [
    (makeDesktopItem {
      name = pname;
      exec = ''"${mainProgram}"'';
      desktopName = mainProgram;
      icon = "pianoteq";
      comment = meta.description;
      categories = [
        "AudioVideo"
        "Audio"
        "Recorder"
      ];
      startupNotify = false;
      inherit startupWMClass;
    })
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    mkdir -p $out/lib/{vst,lv2}

    cp -t $out/bin "${mainProgram}/${archdir}/${mainProgram}"
    cp -t $out/lib/vst "${mainProgram}/${archdir}/${mainProgram}.so"
    cp -r -t $out/lib/lv2 "${mainProgram}/${archdir}/${mainProgram}.lv2"

    install -Dm644 ${./pianoteq.svg} $out/share/icons/hicolor/scalable/apps/pianoteq.svg

    for size in 16 22 32 48 64 128 256; do
      dir=$out/share/icons/hicolor/"$size"x"$size"/apps
      mkdir -p $dir
      rsvg-convert \
        --keep-aspect-ratio \
        --width $size \
        --height $size \
        --output $dir/pianoteq.png \
        ${./pianoteq.svg}
    done

    runHook postInstall
  '';

  postFixup =
    let
      libraryPath = lib.makeLibraryPath (
        buildInputs
        ++ [
          xorg.libXcursor
          xorg.libXinerama
          xorg.libXrandr
          libjack2
          zlib
        ]
      );
    in
    ''
      wrapProgram "$out/bin/${mainProgram}" --prefix LD_LIBRARY_PATH : ${libraryPath}
    '';

  meta = with lib; {
    homepage = "https://www.modartt.com/pianoteq";
    description = "Software synthesizer that features real-time MIDI-control of digital physically modeled pianos and related instruments";
    license = licenses.unfreeRedistributable;
    inherit mainProgram;
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
}
