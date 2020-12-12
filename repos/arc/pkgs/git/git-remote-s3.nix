{ fetchFromGitHub, rustPlatform, hostPlatform, darwin ? null, lib }: rustPlatform.buildRustPackage rec {
  pname = "git-remote-s3";
  version = "0.1.2";
  src = fetchFromGitHub {
    owner = "bgahagan";
    repo = pname;
    rev = "v${version}";
    sha256 = "12lwirmx0c06571chbv0l6xawzl2lv2nmx1pkhfifm3wj909kms4";
  };

  cargoSha256 = "0m0qfsqysh2nqjvjhmv0cng6j02rys40jr9mg5pflp093z00l6cq";

  buildInputs = lib.optional hostPlatform.isDarwin darwin.apple_sdk.frameworks.Security;

  doCheck = false;
}
