{ rustPlatform, fetchFromGitHub, bash, lib }:

rustPlatform.buildRustPackage rec {
  pname = "catp";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "rapiz1";
    repo = "catp";
    rev = "v${version}";
    sha256 = "sha256-yYvJJFXEOxUz+R50ioyHQp3GqF4V8J+vYBPxh4AuA3E=";
  };

  cargoSha256 = "sha256-ErJif5ZOgMPYaUdsaTcLqJVIgl0pYRHdI2+XiNjdee4=";

  checkInputs = [ bash ];
  preCheck = ''
    patchShebangs tests/scripts/*
  '';

  meta = with lib; {
    description = "Print the output of a running process";
    homepage = "https://github.com/rapiz1/catp";
    license = licenses.gpl3;
    maintainers = with maintainers; [ xyenon ];
    platforms = [ "x86_64-linux" ];
  };
}
