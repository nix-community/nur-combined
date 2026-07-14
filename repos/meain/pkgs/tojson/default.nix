{ lib
, fetchFromGitHub
, rustPlatform
, installShellFiles
}:

rustPlatform.buildRustPackage rec {
  pname = "tojson";
  version = "0.3.2";

  src = fetchFromGitHub {
    owner = "meain";
    repo = pname;
    rev = version;
    sha256 = "sha256-l8LS+8jwndJzjAo9bHWqdvViHB3G7U4XgfVHGLspInI=";
  };

  cargoHash = "sha256-dzQ1Q5f1wYpvjc57eGrT0JGSM9rH5/Vfk1Ldd6DGFSE=";

  doInstallCheck = true;

  meta = with lib; {
    homepage = "https://github.com/meain/tojson";
    description = "Convert between yaml, toml and json";
    license = licenses.asl20;
  };
}
