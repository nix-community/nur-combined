{ fetchFromGitHub }:
rec {
  version = "1.14.0";

  src = fetchFromGitHub {
    owner = "Luzifer";
    repo = "ots";
    rev = "v${version}";
    hash = "sha256-kpseR1UPrUNVZJD7MjmIN9l776IQOP4g6ehGTzfaW3I=";
  };
}
