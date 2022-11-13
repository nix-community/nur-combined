{ lib
, fetchFromGitHub
, rustPlatform
, installShellFiles
}:

rustPlatform.buildRustPackage rec {
  pname = "toffee";
  version = "0.5.2";

  src = fetchFromGitHub {
    owner = "meain";
    repo = pname;
    rev = version;
    sha256 = "sha256-Itwz7FdF6cuwEww1/8L8qEvrA3O69isFe4bjuWxXzZA=";
  };

  cargoSha256 = "sha256-4qAIRs649oQHmRTRyAddPXJG3R/Tah7tFRbj/h6L3Xk=";

  doInstallCheck = true;

  meta = with lib; {
    homepage = "https://github.com/meain/toffee";
    description = "Universal test runner";
    license = licenses.asl20;
  };
}
