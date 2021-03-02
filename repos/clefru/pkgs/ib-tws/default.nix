{ pkgs ? import <nixpkgs> {} }:
with pkgs;

stdenv.mkDerivation rec {
  version = "981.2s";
  pname = "ib-tws";

  src = fetchurl {
    url = "https://download2.interactivebrokers.com/installers/tws/latest-standalone/tws-latest-standalone-linux-x64.sh";
    sha256 = "1w0pz57j143d5gjsnkjrs8y03sqhq45k3ss13gbiqf942f54azi5";
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

    # The vmoptions is not writable, so you cannot increase memory from within
    # the application, as the write to the vmoption file will get rejected.
    sed -i 's#-Xmx768m#-Xmx4096m#' $out/libexec/tws.vmoptions

    # We set a bunch of flags found in the Arch PKGBUILD. The flags
    # releated to AA fonts seem to make a positive difference.
    # -Dawt.useSystemAAFontSettings=lcd or -Dawt.useSystemAAFontSettings=on
    # -Dsun.java2d.xrender=True not applied. Results in WARNING: The version of libXrender.so cannot be detected.
    # -Dsun.java2d.opengl=False not applied. Why would I disable that?
    # -Dswing.aatext=true applied
    mkdir $out/bin
    makeWrapper  $out/libexec/tws $out/bin/ib-tws \
      --set INSTALL4J_JAVA_HOME_OVERRIDE ${pkgs.oraclejre8.home} \
      --add-flags '-J-DjtsConfigDir=$HOME/.tws' \
      --add-flags '-J-Dawt.useSystemAAFontSettings=lcd' \
      --add-flags '-J-Dswing.aatext=true'
    # FIXME Fixup .desktop starter.
  '';

  meta = with stdenv.lib; {
    description = "Trader Work Station of Interactive Brokers";
    homepage = "https://www.interactivebrokers.com";
    license = licenses.unfree;
    maintainers = [ maintainers.clefru ];
    platforms = platforms.linux;
  };
}
