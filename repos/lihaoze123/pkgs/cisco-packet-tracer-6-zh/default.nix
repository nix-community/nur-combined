{ lib
, stdenvNoCC
, fetchurl
, fetchFromGitHub
, makeWrapper
, makeDesktopItem
, copyDesktopItems
, dpkg
, patchelf
, pkgsi686Linux
, python3
, requireFile
, qt6
, skipLogin ? true
, enableLegacyExtensions ? false
}:

let
  pname = "cisco-packet-tracer-6-zh";
  version = "6.3.0.0008";
  legacyTranslation = fetchurl {
    url = "https://raw.githubusercontent.com/Hu-Tao-0715/Cisco-PT_ZH-CN/623eca36cfa16354f175c85610b94e122db356c8/6.2/languages/6.2sv_CN.ts";
    hash = "sha256-0nJ+IjxvJnLyRWu568rKR4gk6B/r6+sNhNNvn00Pp8c=";
  };
  legacyTranslationLicense = fetchurl {
    url = "https://raw.githubusercontent.com/Hu-Tao-0715/Cisco-PT_ZH-CN/623eca36cfa16354f175c85610b94e122db356c8/LICENSE";
    hash = "sha256-YF6QR6Vjxcg5b/sYIyqkME7FZYau5TfEUGTG+0JeRK0=";
  };
  translationSource = fetchFromGitHub {
    owner = "Liu8Can";
    repo = "CiscoPacketTracerChinese";
    rev = "4309e76755ff88cd2d2ed72b0e5502785427b28c";
    hash = "sha256-kMqMU300sh3j6c8l/AqktYq5CanUJxeWZrW+37jmv/w=";
  };
  legacyOpenSSL = fetchurl {
    url = "https://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.0.0_1.0.2g-1ubuntu4.20_i386.deb";
    hash = "sha256-DN4G4hDsL6uLQqOApG5Q7u9Mv5AO1JLrhP+JLLXyWTk=";
  };
  runtimeLibraries = with pkgsi686Linux; [
    glibc
    stdenv.cc.cc.lib
    libx11
    libxrender
    libxext
    glib
    zlib
    freetype
    fontconfig
  ];
  runtimeLibraryPath = lib.makeLibraryPath runtimeLibraries;
in
stdenvNoCC.mkDerivation {
  inherit pname version;
  src = requireFile {
    name = "PacketTracer63_linux.tar.gz";
    hash = "sha256-wB8F0xcDgYrDelHwk+gGmwfNEOb/ONYsSu3aRfpF+Cc=";
    url = "https://www.netacad.com/resources/lab-downloads";
  };

  nativeBuildInputs = [ dpkg makeWrapper copyDesktopItems patchelf python3 qt6.qttools ];
  dontConfigure = true;
  dontStrip = true;
  # Qt 6 is used only for lconvert/lrelease; the application ships Qt 4.
  dontWrapQtApps = true;

  postPatch = lib.optionalString skipLogin ''
    python3 ${./patch-login.py} bin/PacketTracer6
  '';

  buildPhase = ''
    runHook preBuild
    ${qt6.qttools}/bin/lconvert -if qm \
      -i '${translationSource}/哔哩哔哩 沧浪同学 中文汉化包.ptl' -of ts -o chinese901.ts
    python3 ${./merge-translations.py} LANGUAGES/default.ts Chinese-6.3.ts \
      ${legacyTranslation} chinese901.ts
    ${qt6.qttools}/bin/lrelease -nounfinished Chinese-6.3.ts -qm Chinese-6.3.ptl
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    pt="$out/opt/pt"
    mkdir -p "$pt" "$out/bin"
    cp -r bin lib LANGUAGES art backgrounds extensions help saves sounds templates "$pt/"
    cp "$pt/LANGUAGES/default.ptl" "$pt/LANGUAGES/English.ptl"
    install -m444 Chinese-6.3.ptl "$pt/LANGUAGES/Chinese-6.3.ptl"
    cp "$pt/LANGUAGES/Chinese-6.3.ptl" "$pt/LANGUAGES/default.ptl"
    install -Dm444 Chinese-6.3.ts "$out/share/${pname}/Chinese-6.3.ts"
    install -Dm444 ${legacyTranslationLicense} \
      "$out/share/licenses/${pname}/translation-6.2-LICENSE"
    install -Dm444 ${translationSource}/LICENSE \
      "$out/share/licenses/${pname}/translation-9.0.1-LICENSE"
    install -Dm444 eula.txt "$out/share/licenses/${pname}/Cisco-EULA.txt"

    dpkg-deb -x ${legacyOpenSSL} legacy-openssl
    install -m755 legacy-openssl/lib/i386-linux-gnu/lib{crypto,ssl}.so.1.0.0 "$pt/lib/"
    install -Dm444 legacy-openssl/usr/share/doc/libssl1.0.0/copyright \
      "$out/share/licenses/${pname}/OpenSSL-copyright"

    # The top-level zip uses obsolete libc.so.5; the shipped Linux/ versions
    # use glibc and preserve the command line expected by Packet Tracer.
    install -m755 bin/Linux/zip bin/Linux/unzip "$pt/bin/"
    rm -r "$pt/bin/Linux"

    ${lib.optionalString (!enableLegacyExtensions) ''
      # Legacy signed scripts fail certificate validation on current dates,
      # and external apps expect an old Linux/Java environment. Preserve their
      # original files outside the auto-loaded extensions directory.
      mkdir -p "$out/share/${pname}/disabled-extensions"
      for extension in ClearTerminalAgent LanMultiuserAgent Marvel PcSoftware WanMultiuserAgent upnp ptaplayer; do
        mv "$pt/extensions/$extension" "$out/share/${pname}/disabled-extensions/"
      done
    ''}

    for executable in "$pt"/bin/{PacketTracer6,linguist,zip,unzip} "$pt"/extensions/meta; do
      patchelf --set-interpreter ${pkgsi686Linux.stdenv.cc.bintools.dynamicLinker} \
        --set-rpath "$pt/lib:${runtimeLibraryPath}" "$executable"
    done
    for shared in "$pt"/lib/*.so.* "$pt"/bin/imageformats/*.so "$pt"/bin/accessible/*.so; do
      if [ ! -L "$shared" ]; then
        patchelf --set-rpath "$pt/lib:${runtimeLibraryPath}" "$shared"
      fi
    done

    makeWrapper "$pt/bin/PacketTracer6" "$out/bin/packettracer6-zh" \
      --set PT6HOME "$pt" \
      --set QT_PLUGIN_PATH "$pt/bin" \
      --set LD_LIBRARY_PATH "$pt/lib:${runtimeLibraryPath}" \
      --prefix PATH : "$pt/bin" \
      --run 'ptArgs=(); for ptArg in "$@"; do
        if [[ "$ptArg" != /* && -f "$ptArg" ]]; then ptArg="$PWD/$ptArg"; fi
        ptArgs+=("$ptArg")
      done; set -- "''${ptArgs[@]}"' \
      --chdir "$pt/bin"

    install -Dm444 art/app.png "$out/share/icons/hicolor/48x48/apps/${pname}.png"
    for mime in pkt pka pkz; do
      install -Dm444 "bin/Cisco-$mime.xml" \
        "$out/share/mime/packages/${pname}-$mime.xml"
    done
    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = pname;
      desktopName = "Cisco Packet Tracer 6.3（简体中文）";
      exec = "packettracer6-zh %f";
      icon = pname;
      startupWMClass = "PacketTracer6";
      categories = [ "Education" "Network" ];
      mimeTypes = [ "application/x-pkt" "application/x-pka" "application/x-pkz" ];
    })
  ];

  passthru = { inherit legacyOpenSSL legacyTranslation translationSource skipLogin enableLegacyExtensions; };
  meta = {
    description = "Cisco Packet Tracer 6.3 with Simplified Chinese translation and optional offline login patch";
    homepage = "https://www.netacad.com/courses/packet-tracer";
    license = [ lib.licenses.unfree lib.licenses.gpl3Plus lib.licenses.mit lib.licenses.openssl ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "packettracer6-zh";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
