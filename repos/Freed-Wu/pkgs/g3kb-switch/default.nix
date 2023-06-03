{ mySources
, lib
, stdenv
, cmake
, pkg-config
, glib
  # , bash-completion
}:
stdenv.mkDerivation rec {
  inherit (mySources.g3kb-switch) pname version src;
  nativeBuildInputs = [
    cmake
    pkg-config
    glib
    # bash-completion
  ];
  patchPhase = ''
    sed -i 's=/usr/=''${CMAKE_INSTALL_PREFIX}=g' CMakeLists.txt
    sed -i 's=\\\''${prefix}/==g' CMakeLists.txt
    mkdir -p $out/share/gnome-shell/extensions
    cp -r extension/g3kb-switch@g3kb-switch.org -t $out/share/gnome-shell/extensions
  '';

  meta = with lib; {
    homepage = "https://github.com/lyokha/g3kb-switch";
    description = "CLI keyboard layout switcher for Gnome Shell";
    license = licenses.bsd2;
    maintainers = with maintainers; [ ];
    platforms = platforms.unix;
  };
}
