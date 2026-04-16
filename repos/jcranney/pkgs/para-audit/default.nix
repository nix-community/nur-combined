{ 
  rustPlatform, lib, fetchgit, pkgs
}:
rustPlatform.buildRustPackage rec {
  
  pname = "para-audit";
  version = "v0.1.15";

  cargoHash = "sha256-AAeykJIyNNw6xm4g0YBDb3zuNYj/8AKhDAHu9PtUNLs=";

  nativeBuildInputs = [ pkgs.pkg-config ];
  buildInputs = [ pkgs.openssl ];

  src = fetchgit {
    url = "https://github.com/jcranney/para-audit.git";
    tag = version;
    hash = "sha256-bS0Up3MBUHEZclTOHLo6QWhmgJH7cam6/XJnnzD4UpY=";
  };

  meta = with lib; {
    description = "A tool for auditing/organising/interacting with my para system.";
    homepage = https://github.com/jcranney/para-audit;
    license = licenses.unlicense;
    platforms = platforms.all;
    mainProgram = "para";
  };
}