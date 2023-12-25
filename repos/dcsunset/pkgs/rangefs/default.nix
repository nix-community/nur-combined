{ lib, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "rangefs";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "DCsunset";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-iP67hQI70p0BjRhQA7dGLREpyW5bxJaVFCxBpDTlTuo=";
  };

  # run prefetch-npm-deps package-lock.json to generate the hash
  cargoHash = "sha256-faOH+fyDZnjvIPKAFx/7/k2P0Q1rNlN/l+7bcOvwsoU=";

  meta = with lib; {
    description = "A fuse-based filesystem to map ranges in file to individual files.";
    homepage = "https://github.com/DCsunset/rangefs";
    license = licenses.agpl3;
  };
}
