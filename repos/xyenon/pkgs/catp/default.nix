{ rustPlatform, fetchFromGitHub, bash, lib, nix-update-script }:

rustPlatform.buildRustPackage rec {
  name = "catp";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "rapiz1";
    repo = name;
    rev = "v${version}";
    sha256 = "sha256-yYvJJFXEOxUz+R50ioyHQp3GqF4V8J+vYBPxh4AuA3E=";
  };

  cargoSha256 = "sha256-21zcL3ibhfVIqsX6UCN30V0XGHBiIAfzjMBkHFoGckg=";

  checkInputs = [ bash ];
  preCheck = ''
    patchShebangs tests/scripts/*
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Print the output of a running process";
    homepage = "https://github.com/rapiz1/catp";
    license = licenses.gpl3;
    maintainers = with maintainers; [ xyenon ];
    platforms = [ "x86_64-linux" ];
  };
}
