{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  dpkg,
  gtk3,
  libnotify,
  libepoxy,
  webkitgtk_4_1,
  libX11,
  libxdamage,
  libxcomposite,
  libXtst,
  libxcrypt,
  libappindicator-gtk3,
  glibc,
}:

let
  libcryptStub = stdenv.mkDerivation {
    name = "libcrypt-stub";
    dontUnpack = true;
    dontBuild = true;
    installPhase = ''
      mkdir -p $out/lib
      cat > $out/lib/version.script << 'VEOF'
GLIBC_2.2.5 {
    global: *; local: *;
};
VEOF
      ${stdenv.cc}/bin/gcc -shared \
        -Wl,--version-script=$out/lib/version.script \
        -Wl,-soname,libcrypt.so.1 \
        -o $out/lib/libcrypt.so.1 \
        -xc /dev/null
      rm $out/lib/version.script
    '';
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "sunloginclient";
  version = "16.5.0.30560";

  src = fetchurl {
    url = "https://down.oray.com/sl/linux/awesun-${finalAttrs.version}-x86_64.deb";
    hash = "sha256-7aP//m1TJK+8T5OfDLhcCLeFHvrTwBh4YhR07HUD0Q8=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
  ];

  buildInputs = [
    gtk3
    libnotify
    libepoxy
    webkitgtk_4_1
    libX11
    libxdamage
    libxcomposite
    libXtst
    libxcrypt
    libappindicator-gtk3
    libcryptStub
  ];
  runtimeDependencies = [ glibc ];
  patchelfFlags = [ "--force-rpath" ];

  dontConfigure = true;
  dontBuild = true;

  unpackPhase = ''
    runHook preUnpack
    mkdir -p build
    dpkg-deb -x $src build
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share $out/opt
    cp -r build/usr/local/awesun $out/opt/

    chmod +x $out/opt/awesun/awesun
    chmod +x $out/opt/awesun/bin/awesun_daemon
    chmod +x $out/opt/awesun/bin/awesun_desktop

    ln -s ../opt/awesun/awesun $out/bin/sunloginclient

    mkdir -p $out/share/applications
    cp build/usr/share/applications/awesun.desktop $out/share/applications/ || true
    substituteInPlace $out/share/applications/awesun.desktop \
      --replace "/usr/local/awesun/awesun" "sunloginclient"
    mkdir -p $out/share/pixmaps
    cp build/usr/local/awesun/awesun.png $out/share/pixmaps/sunloginclient.png 2>/dev/null || true

    runHook postInstall
  '';

  meta = {
    description = "Sunlogin remote desktop client (向日葵远程控制)";
    homepage = "https://sunlogin.oray.com";
    license = lib.licenses.unfree;
    mainProgram = "sunloginclient";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ MCSeekeri ];
  };
})
