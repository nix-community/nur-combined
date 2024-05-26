{ lib

, fetchFromGitHub

, rustPlatform
}:
rustPlatform.buildRustPackage rec {
  pname = "lddtree";
  version = "0.3.4";

  src = fetchFromGitHub {
    owner = "messense";
    repo = "lddtree-rs";
    rev = "v${version}";
    hash = "sha256-BlwnWG7Xbh6F4CutWvTF/Q5YzwxWmTB/b/jd8EAEO7k=";
  };

  cargoHash = "sha256-SsFSAIZL3zkf/xNFEfceOShJo5CGL/igUYfOjNwh2Dk=";

  meta = with lib; {
    description = "Read the ELF dependency tree";
    homepage = "https://github.com/messense/lddtree-rs";
    license = licenses.mit;
    mainProgram = "lddtree";
  };
}
