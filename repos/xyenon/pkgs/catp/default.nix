{
  rustPlatform,
  fetchFromGitHub,
  bash,
  lib,
  nix-update-script,
}:

rustPlatform.buildRustPackage rec {
  pname = "catp";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "rapiz1";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-yYvJJFXEOxUz+R50ioyHQp3GqF4V8J+vYBPxh4AuA3E=";
  };

  cargoHash = "sha256-Tv//xNq85Cc11lfdt5SF2Vlo9/O/PHINc+eRGV+8irI=";

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
