{ lib, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "jaq";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "01mf02";
    repo = "jaq";
    rev = "v${version}";
    hash = "sha256-4WCVXrw/v3cGsl7S1nGqKmWrIHeM/ODCXQBxQJgZLjw=";
  };

  cargoHash = "sha256-D+Wpzgj05PJcMlGS9eL43SdncHO/q1Wt00gvPlC7ZAE=";

  meta = with lib; {
    description = "Jq clone focused on correctness, speed and simplicity";
    homepage = "https://github.com/01mf02/jaq";
    license = with licenses; [ mit ];
  };
}
