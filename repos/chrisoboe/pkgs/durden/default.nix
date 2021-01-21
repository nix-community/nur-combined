{ stdenv, fetchFromGitHub, bash, arcan}:

stdenv.mkDerivation rec {
  pname = "durden";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "letoram";
    repo = "durden";
    rev = "${version}";
    sha256 = "03ry8ypsvpjydb9s4c28y3iffz9375pfgwq9q9y68hmj4d89bjvz";
  };

  buildInputs = [
    arcan
  ];

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

    echo -e "\
#!${bash}/bin/bash

# check if XDG_RUNTIME_DIR needs to be set
if [[ -z "'"$XDG_RUNTIME_DIR"'" ]];
then
  export XDG_RUNTIME_DIR=/run/user/"'$UID'"
  mkdir -p "'$XDG_RUNTIME_DIR'"
  chmod 700 "'$XDG_RUNTIME_DIR'"
fi

# check if we have a suid wrapper for arcan
if [[ -f "/run/wrappers/bin/arcan" ]];
then
  exec /run/wrappers/bin/arcan $out/share/durden
else
  ${arcan}/bin/arcan $out/share/durden
fi
    " > $out/bin/durden

    chmod +x $out/bin/durden

    echo -e "\
[Desktop Entry]
Name=durden
Comment=Next Generation Window Manager
Exec=$out/bin/durden
Type=Application
" > $out/share/wayland-sessions/durden.desktop

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

