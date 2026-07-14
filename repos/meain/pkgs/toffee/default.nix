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

  cargoHash = "sha256-0AEWOvVSb+69TZpOltuHXS3mdBR5XE3DkE0c56mXDZs=";

  doInstallCheck = true;

  meta = with lib; {
    homepage = "https://github.com/meain/toffee";
    description = "Universal test runner";
    license = licenses.asl20;
  };
}
