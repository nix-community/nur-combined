{
  # keep-sorted start
  fetchFromGitHub,
  lib,
  rustPlatform,
  # keep-sorted end
}:
rustPlatform.buildRustPackage rec {
  pname = "zfetch-rs";
  version = "2.8.0";

  src = fetchFromGitHub {
    owner = "ferret-linux";
    repo = pname;
    tag = "v${version}";
    hash = "sha256-yNkr/lk4akDMiRs0usix76LXpiLqJysFW+7Y3ERB+Wk=";
  };

  cargoHash = "sha256-BQIvueWvO/iLnguou6Q3c5RST+RaBX8OZoX/aTaHebM=";

  meta = with lib; {
    # keep-sorted start
    description = "A rewrite of zfetch in Rust";
    homepage = "https://github.com/ferret-linux/zfetch-rs";
    license = licenses.mpl20;
    mainProgram = "zfetch";
    platforms = platforms.unix;
    # keep-sorted end
  };
}
