{ lib, stdenv, autoPatchelfHook, buildFHSUserEnv, fetchzip
, dbus, fontconfig, freetype, libxkbcommon, xorg, zlib
}:

let
  pname = "010-editor";
  version = "10.0.2";
  description =
    "Professional text and hex editing with Binary Templates technology";

  desktopFile = builtins.toFile "${pname}-${version}.desktop" ''
    [Desktop Entry]
    Name=010 Editor
    Comment=${description}
    Icon=010editor
    Exec=010editor
    Terminal=false
    Type=Application
    Categories=Development;
  '';

  prefix = ''"$out"/opt/${pname}'';
  execFHSEnv = buildFHSUserEnv { name = "exec"; runScript = ""; };
in stdenv.mkDerivation {
  inherit pname version;

  src = let
    # v = lib.replaceStrings [ "." ] [ "" ] version;
    v = version;
  in fetchzip {
    url =
      "https://download.sweetscape.com/010EditorLinux64Installer${v}.tar.gz";
    stripRoot = false;
    sha256 = "03lj0cq5wl8z00g37d3zpyf1nf838ra04sbwx4dp3hsabzc2wzy5";
  };

  buildInputs = builtins.map lib.getLib [
    dbus
    fontconfig
    freetype
    libxkbcommon
    xorg.libxcb
    zlib
  ];

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildPhase = ''
    runHook preBuild
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    ${execFHSEnv}/bin/exec ./010EditorLinux64Installer \
      --mode silent --prefix ${prefix}
    runHook postInstall
  '';

  postInstall = ''
    rm -r ${prefix}/{assistant,uninstall}
    mkdir -p "$out"/{bin,share/{pixmaps,licenses/010-editor}}
    ln -s ${prefix}/010editor "$out"/bin/010editor
    ln -s ${prefix}/010_icon_128x128.png "$out"/share/pixmaps/010editor.png
    ln -s ${prefix}/license.txt "$out"/share/licenses/010-editor/license.txt
    install -Dm644 ${desktopFile} "$out"/share/applications/010editor.desktop
  '';

  preFixup = ''
    addAutoPatchelfSearchPath ${stdenv.cc.cc}/lib
  '';

  meta = {
    inherit description;
    license = lib.licenses.unfree;
    homepage = "https://www.sweetscape.com/010editor/";
    maintainers = let m = lib.maintainers; in [ m.bb010g ];
    platforms = lib.platforms.linux;
  };
}
