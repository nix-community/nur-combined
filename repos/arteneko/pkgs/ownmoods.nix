{ rustPlatform, lib, fetchFromSourcehut, sqlx-cli, libsodium, sqlite, pkg-config }:
let
  ref = "f402f31";
in rustPlatform.buildRustPackage rec {
  pname = "ownmoods";
  version = "dev-${ref}";
  
  nativeBuildInputs = [
    pkg-config
    libsodium sqlite
    sqlx-cli
  ];
  
  src = fetchFromSourcehut {
    owner = "~artemis";
    repo = pname;
    rev = ref;
    sha256 = "sha256-DgbxpJjrpOyRIDrfyLAz1sPN3DtJ+z3pZvefGHCSOVE=";
  };
  
  cargoSha256 = "sha256-hCoXmlp+HEoWa+dWcmApa9VJQA5GkYuBTmZLVJY61gg=";
  
  preBuild =
    ''
    sqlx database create
    sqlx migrate run
    '';
    
  postInstall =
    ''
    mkdir -p $out/lib/${pname}
    cp -r assets $out/lib/${pname}
    '';
  
  meta = with lib; {
    description = "A simple self-hosted mood tracker";
    homepage = "https://git.sr.ht/~artemis/ownmoods";
  };
}
