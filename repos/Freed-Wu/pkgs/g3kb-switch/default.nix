{ lib
, stdenv
, cmake
, pkg-config
, glib
, fetchFromGitHub
}:
stdenv.mkDerivation rec {
  pname = "g3kb-switch";
  version = "1.3";
  src = fetchFromGitHub {
    owner = "lyokha";
    repo = "g3kb-switch";
    rev = version;
    sha256 = "sha256-QLTRM2GXSxvvVYOMq6QL44zZvoGkiolTLZ1u7dB7dt4=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];
  buildInputs = [
    glib
  ];
  cmakeFlags = [
    "-DG3KBSWITCH_VIM_XKBSWITCH_LIB_PATH=lib"
    "-DBASH_COMPLETION_COMPLETIONSDIR=${placeholder "out"}/share/bash-completions/completions"
    "-DZSH_COMPLETION_COMPLETIONSDIR=${placeholder "out"}/share/zsh/site-functions"
  ];

  meta = with lib; {
    homepage = "https://github.com/lyokha/g3kb-switch";
    description = "CLI keyboard layout switcher for GNOME Shell";
    license = licenses.bsd2;
    maintainers = with maintainers; [ Freed-Wu ];
    platforms = platforms.unix;
  };
}
