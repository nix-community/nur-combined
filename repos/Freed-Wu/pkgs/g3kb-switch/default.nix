{ lib
, stdenv
, cmake
, pkg-config
, glib
, fetchFromGitHub
  # , bash-completion
}:
stdenv.mkDerivation rec {
  pname = "gnome-shell-extension-g3kb-switch";
  version = "1.2";
  src = fetchFromGitHub {
    owner = "lyokha";
    repo = "g3kb-switch";
    rev = version;
    sha256 = "sha256-Nq2psfy51hZQEm57PUSvs17Pp2z6pe30h9BOLbOYV4k=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    # bash-completion
  ];
  buildInputs = [
    glib
  ];
  prePatch = ''
    sed -i 's=/usr/=''${CMAKE_INSTALL_PREFIX}=g' CMakeLists.txt
    sed -i 's=\\\''${prefix}/==g' CMakeLists.txt
    install -d $out/share/gnome-shell/extensions
    cp -r extension/g3kb-switch@g3kb-switch.org -t $out/share/gnome-shell/extensions
  '';

  meta = with lib; {
    homepage = "https://github.com/lyokha/g3kb-switch";
    description = "CLI keyboard layout switcher for GNOME Shell";
    license = licenses.bsd2;
    maintainers = with maintainers; [ Freed-Wu ];
    platforms = platforms.unix;
  };
}
