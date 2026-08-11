{ lib
, go
, stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  pname = "tap-bpm-cli";
  version = "unstable-2019-02-24";

  src = fetchFromGitHub {
    owner = "marakoss";
    repo = "tap-bpm-cli";
    rev = "4856fa15b0d4aea7dfe426637336fe77614cddad";
    hash = "sha256-nUERBFUUj+I1am2i/YgTPJz7h8yraS/4vLP3F846TpE=";
  };

  nativeBuildInputs = [
    go
  ];

  # fix: failed to initialize build cache at /homeless-shelter/.cache/go-build: mkdir /homeless-shelter: permission denied
  #export HOME=$TMP

  buildPhase = ''
    export HOME=$TMP

    go build tap-bpm-cli.go
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp tap-bpm-cli $out/bin/tap-bpm-cli
  '';

  meta = with lib; {
    description = "Tap to BPM counter tool for CLI";
    homepage = "https://github.com/marakoss/tap-bpm-cli";
    license = with licenses; [ ];
    maintainers = with maintainers; [ ];
  };
}
