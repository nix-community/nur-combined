{ fetchFromGitHub }:

rec {
  version = "0.20.1";
  src = fetchFromGitHub {
    owner = "zed-industries";
    repo = "delta-nix";
    tag = "v${version}";
    hash = "sha256-qT0ZdH+i4cK/4pMb+SxMneyPbOSYkwdp5QF8kkQrNBQ=";
  };
}
