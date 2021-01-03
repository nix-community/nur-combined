{ stdenv, fetchFromGitHub, bash}:

stdenv.mkDerivation rec {
  pname = "durden";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "letoram";
    repo = "durden";
    rev = "${version}";
    sha256 = "03ry8ypsvpjydb9s4c28y3iffz9375pfgwq9q9y68hmj4d89bjvz";
  };

  dontConfigure = true;
  dontBuild = true;

  patchPhase = ''
    sed -i "s,/usr/share/,$out/share/,g" ./distr/durden
  '';

  # TODO: this is pretty ugly. propably there are nice nix tools for this stuff
  # this relies on having arcan configured as suid binary so /run/wrappers/bin/arcan exists
  installPhase = ''
    mkdir -p $out/share/wayland-sessions
    mkdir -p $out/bin
    cp -r ./durden $out/share/
    echo -e "#!${bash}/bin/bash\nexec /run/wrappers/bin/arcan $out/share/durden" > $out/bin/durden
    chmod +x $out/bin/durden
    echo -e "[Desktop Entry]\nName=durden\nComment=Next Generation Window Manager\nExec=$out/bin/durden\nType=Application" > $out/share/wayland-sessions/durden.desktop
    chmod +x $out/share/wayland-sessions/durden.desktop
  '';

  meta = with stdenv.lib; {
    homepage = "https://durden.arcan-fe.com";
    description = "Next Generation Desktop Environment";
    platforms = platforms.linux;
    maintainers = [ "chris@oboe.email" ];
  };

  passthru.providedSessions = [ "durden" ];
}

