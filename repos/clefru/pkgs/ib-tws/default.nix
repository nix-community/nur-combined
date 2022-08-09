{ pkgs ? import <nixpkgs> {} }:
with pkgs;

let ibDerivation = stdenv.mkDerivation rec {
  version = "10.17.1s";
  pname = "ib-tws-native";

  src = fetchurl {
    url = "https://download2.interactivebrokers.com/installers/tws/latest-standalone/tws-latest-standalone-linux-x64.sh";
    sha256 = "0acwdrmflmz926fxbvb2c2b51g7c1y2wjqxihni9gk0css1ymj88";
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
    ${buildFHSUserEnv { name = "fhs"; }}/bin/fhs ${src} -q -dir $out/libexec

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
    sed -e s#__OUT__#$out# -e s#__JAVAHOME__#${pkgs.oraclejre8.home}# -e s#__GTK__#${pkgs.gtk3}# -e s#__CCLIBS__#${pkgs.stdenv.cc.cc.lib}# ${./tws-wrap.sh} > $out/bin/ib-tws-native

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
in buildFHSUserEnv {
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
  ];
  runScript = "/usr/bin/ib-tws-native";
}
