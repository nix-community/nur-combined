{ lib
, appimageTools
, dpkg
, fetchFromGitHub
, libpng
, libxkbfile
, python3
, requireFile
, stdenvNoCC
, skipLogin ? true
}:

let
  pname = "cisco-packet-tracer-zh";
  version = "9.0.1";
  translationSource = fetchFromGitHub {
    owner = "Liu8Can";
    repo = "CiscoPacketTracerChinese";
    rev = "4309e76755ff88cd2d2ed72b0e5502785427b28c";
    hash = "sha256-kMqMU300sh3j6c8l/AqktYq5CanUJxeWZrW+37jmv/w=";
  };
  appimage = stdenvNoCC.mkDerivation {
    pname = "cisco-packet-tracer-appimage";
    inherit version;
    src = requireFile {
      name = "CiscoPacketTracer_901_Ubuntu_64bit.deb";
      hash = "sha256-NoPdh+d5iFNyrpo1wabllNEvST5knnxpdAhynBRZR5s=";
      url = "https://www.netacad.com/resources/lab-downloads";
    };
    nativeBuildInputs = [ dpkg ];
    installPhase = ''
      runHook preInstall
      cp opt/pt/packettracer.AppImage "$out"
      runHook postInstall
    '';
  };
  contents = appimageTools.extract {
    inherit pname version;
    src = appimage;
    postExtract = ''
      chmod -R u+w "$out/opt/pt/languages"
      cp "$out/opt/pt/languages/default.ptl" "$out/opt/pt/languages/English.ptl"
      install -m444 '${translationSource}/哔哩哔哩 沧浪同学 中文汉化包.ptl' \
        "$out/opt/pt/languages/Chinese-9.0.1.ptl"
      cp "$out/opt/pt/languages/Chinese-9.0.1.ptl" "$out/opt/pt/languages/default.ptl"
      # CLanguageHandler uses applicationDirPath() + "/../LANGUAGES/" on Linux too.
      ln -s languages "$out/opt/pt/LANGUAGES"
      ${lib.optionalString skipLogin ''
        chmod u+w "$out/opt/pt/bin/PacketTracer"
        ${python3}/bin/python3 ${./patch-login.py} "$out/opt/pt/bin/PacketTracer"
      ''}
    '';
  };
in
appimageTools.wrapAppImage {
  inherit pname version;
  src = contents;
  extraPkgs = _: [ libpng libxkbfile ];
  extraBwrapArgs = [ "--setenv QT_QPA_PLATFORM xcb" ];
  extraInstallCommands = ''
    mv "$out/bin/${pname}" "$out/bin/packettracer9-zh"
    install -Dm444 ${contents}/CiscoPacketTracer-9.0.1.desktop \
      "$out/share/applications/cisco-packet-tracer-zh.desktop"
    install -Dm444 ${contents}/CiscoPacketTracerPtsa-9.0.1.desktop \
      "$out/share/applications/cisco-packet-tracer-ptsa-zh.desktop"
    substituteInPlace "$out"/share/applications/*.desktop \
      --replace-fail 'Exec=@EXEC_PATH@' "Exec=$out/bin/packettracer9-zh" \
      --replace-fail 'Icon=app' 'Icon=cisco-packet-tracer-zh'
    for desktop in "$out"/share/applications/*.desktop; do
      sed -i '/^\[Desktop Entry\]/a StartupWMClass=PacketTracer' "$desktop"
    done
    sed -i 's/^Name=.*/Name=Cisco Packet Tracer（简体中文）/' \
      "$out/share/applications/cisco-packet-tracer-zh.desktop"
    install -Dm444 ${contents}/usr/share/icons/hicolor/48x48/apps/app.png \
      "$out/share/icons/hicolor/48x48/apps/cisco-packet-tracer-zh.png"
    cp -r ${contents}/usr/share/icons/gnome/48x48/mimetypes "$out/share/icons/hicolor/48x48/"
    cp -r ${contents}/usr/share/mime "$out/share/"
    install -Dm444 ${translationSource}/LICENSE \
      "$out/share/licenses/${pname}/translation-LICENSE"
  '';
  passthru = { inherit contents translationSource skipLogin; };
  meta = {
    description = "Cisco Packet Tracer with Simplified Chinese translation and optional offline login patch";
    homepage = "https://www.netacad.com/courses/packet-tracer";
    license = [ lib.licenses.unfree lib.licenses.mit ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "packettracer9-zh";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
