{ 
  stdenv, fetchFromGitHub, rustPlatform, lib, pkgs
}:
rustPlatform.buildRustPackage rec {
  
  pname = "mount-clt";
  version = "v0.1.1";

  cargoLock.lockFile = "${src}/Cargo.lock";

  nativeBuildInputs = [ pkgs.pkg-config ];
  buildInputs = [ pkgs.openssl ];

  src = fetchFromGitHub {
    owner = "jcranney";
    repo = pname;
    rev = version;
    hash = "sha256-w63u5JFJrw8+kiE3f+DCzEGB2oM+VZdy79DGewR1xVs=";
  };

  meta = with lib; {
    description = "A tool for controlling my telescope mount";
    homepage = https://github.com/jcranney/mount-clt;
    license = licenses.unlicense;
    platforms = platforms.all;
  };
}
