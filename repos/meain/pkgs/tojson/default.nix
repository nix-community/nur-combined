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

  cargoSha256 = "sha256-ja2dlO0FbZ7ppQ/Se82n/zR49+NI+A/QDaxIRg+CzqI=";

  doInstallCheck = true;

  meta = with lib; {
    homepage = "https://github.com/meain/tojson";
    description = "Convert between yaml, toml and json";
    license = licenses.asl20;
  };
}
