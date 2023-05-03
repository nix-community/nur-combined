{ lib
, fetchFromGitHub
, rustPlatform
}:

rustPlatform.buildRustPackage rec {
  pname = "iamb";
  # renovate: datasource=github-releases depName=ulyssa/iamb
  version = "0.0.7";
  src = fetchFromGitHub {
    owner = "ulyssa";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-KKr7dfFSffkFgqcREy/3RIIn5c5IxhFR7CjFJqCmqdM=";
  };
  cargoSha256 = "sha256-/OBGRE9zualLnMh9Ikh9s9IE9b8mEmAC/H5KUids8a8=";

  meta = with lib; {
    description = " A Matrix client for Vim addicts";
    homepage = "https://github.com/ulyssa/iamb";
    license = licenses.asl20;
  };
}
