{ pkgs ? import <nixpkgs> {} }:
with pkgs;

let
  jdkWithJavaFX = (pkgs.jdk11.override {
    enableJavaFX = true;
    openjfx_jdk = openjfx17.override { withWebKit = true; };
#    openjfx17 = openjfx17.override { withWebKit = true; };
#    openjfx21 = openjfx21.override { withWebKit = true; };
#    openjfx23 = openjfx23.override { withWebKit = true; };
  });
  ibDerivation = stdenv.mkDerivation rec {
  version = "10.40.1c";
  pname = "ib-tws-native";

  src = fetchurl {
    url = "https://download2.interactivebrokers.com/installers/tws/latest-standalone/tws-latest-standalone-linux-x64.sh";
    sha256 = "1g0jwrcfiyj0w1ya97x3jqy7z3wp1vdprf3bpiw6wlj1s3m839n5";
    executable = true;
  };

  # Only build locally for license reasons.
  preferLocalBuild = true;

  phases = [ "installPhase" ];

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    # We use an installer FHS environment because the shell script unpacks
    # a binary, and immediately calls that binary. There is little hope
    # for us to patchelf ld-linux in between. An FHS env is easier.
    ${buildFHSEnvChroot { name = "fhs";
                    targetPkgs = pkgs1: [
                      libz
                    ];
                  }}/bin/fhs ${src} -q -dir $out/libexec

    # The following disables the JRE compatability check inside the tws script
    # so that we can use Oracle JRE pkgs of nixpkgs.
    sed -i 's#test_jvm "$INSTALL4J_JAVA_HOME_OVERRIDE"#app_java_home="$INSTALL4J_JAVA_HOME_OVERRIDE"#' $out/libexec/tws

    # Make the tws launcher script read $HOME/.tws/tws.vmoptions
    # instead of the unmutable version in $out.
    sed -i -e 's#read_vmoptions "$prg_dir/$progname.vmoptions"#read_vmoptions "$HOME/.tws/$progname.vmoptions"#' $out/libexec/tws

    # We set a bunch of flags found in the Arch PKGBUILD. The flags
    # releated to AA fonts seem to make a positive difference.
    # -Dawt.useSystemAAFontSettings=lcd or -Dawt.useSystemAAFontSettings=on
    # -Dsun.java2d.xrender=True not applied. Results in WARNING: The version of libXrender.so cannot be detected.
    # -Dsun.java2d.opengl=False not applied. Why would I disable that?
    # -Dswing.aatext=true applied
    mkdir $out/bin
    sed -e s#__OUT__#$out# -e s#__JAVAHOME__#${jdkWithJavaFX.home}# -e s#__GTK__#${pkgs.gtk3}# -e s#__CCLIBS__#${pkgs.stdenv.cc.cc.lib}# ${./tws-wrap.sh} > $out/bin/ib-tws-native

    chmod a+rx $out/bin/ib-tws-native

    # FIXME Fixup .desktop starter.
  '';

  meta = with lib; {
    description = "Trader Work Station of Interactive Brokers";
    homepage = "https://www.interactivebrokers.com";
    license = licenses.unfree;
    maintainers = [ maintainers.clefru ];
    platforms = platforms.linux;
  };
};
# IB TWS packages the JxBrowser component. It unpacks a pre-built
# Chromium binary (yikes!) that needs an FHS environment. For me, that
# doesn't yet work, and the chromium fails to launch with an error
# code.
in buildFHSEnv {
  name = "ib-tws";
  targetPkgs = pkgs1: [
    ibDerivation

    # Chromium dependencies. This might be incomplete.
    xorg.libXfixes
    alsa-lib
    xorg.libXcomposite
    cairo
    xorg.libxcb
    pango
    glib
    atk
    at-spi2-core
    at-spi2-atk
    xorg.libXext
    libdrm
    nspr
    #xorg.libxkbcommon
    nss
    cups
    mesa
    expat
    dbus
    xorg.libXdamage
    xorg.libXrandr
    xorg.libX11
    xorg.libxshmfence
    libxkbcommon
    systemd # for libudev.so.1
  ];
  runScript = "/usr/bin/ib-tws-native";
}
