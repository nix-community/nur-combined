{ lib
, fetchFromGitHub
, rustPlatform
, pkg-config
, cmake
, openssl
, glib
, gdk-pixbuf
, alsa-lib
, libnotify
, libopus
}:

rustPlatform.buildRustPackage rec {
  pname = "keyboard_layout_optimizer";
  name = "${pname}-git";
  src = fetchFromGitHub {
    owner = "dariogoetz";
    repo = pname;
    rev = "f93bd06820790ae746fbe66445bdf4427260fd31";
    hash = "sha256-rZcsPuJDKXFEBDldrKky52wBaoRloYGKAN3AwkgMS6E=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
  };

postPatch = ''
  ln -s ${./Cargo.lock} Cargo.lock
'';

  nativeBuildInputs = [
    pkg-config
    cmake
  ];

  buildInputs = [
    openssl
    # glib
    # gdk-pixbuf
    # alsa-lib
    # libnotify
    # libopus
  ];

  meta = with lib; {
    description = "A keyboard layout optimizer supporting multiple layers. Implemented in Rust. ";
    homepage = "https://github.com/dariogoetz/keyboard_layout_optimizer";
    license = licenses.gpl3;
  };
}
