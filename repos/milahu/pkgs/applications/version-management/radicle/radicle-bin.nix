{ lib
, stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  pname = "radicle-bin";

  # version is printed by: radicle-node --help # TODO better?
  version = "0.2.0-unstable-${versionDate}";

  # https://github.com/radicle-dev/heartwood/commit/594381d051b06a87dc9f517e99cc0d524274c6a9
  versionCommit = "594381d051b06a87dc9f517e99cc0d524274c6a9";

  versionDate = "2023-04-07";

  src = ({
    x86_64-linux = fetchurl {
      url = "https://files.radicle.xyz/${versionCommit}/x86_64-unknown-linux-musl/radicle-x86_64-unknown-linux-musl.tar.gz";
      sha256 = "sha256-PR3CbYHi0VtXStr40dYSwWvvlni0TaN7V7TqfU0YzUE=";
    };
    x86_64-darwin = fetchurl {
      url = "https://files.radicle.xyz/${versionCommit}/x86_64-apple-darwin/radicle-x86_64-apple-darwin.tar.gz";
      sha256 = "sha256-L6od5tjYQCEJD8A8dgq2OWzkDszWCCctbfYuiHRkqOc=";
    };
    aarch64-linux = fetchurl {
      url = "https://files.radicle.xyz/${versionCommit}/aarch64-unknown-linux-musl/radicle-aarch64-unknown-linux-musl.tar.gz";
      sha256 = "sha256-jLCgq6omOCNJ1u5pk22qpRC5VbPPfKR/ZLDITOmgU3Q=";
    };
    aarch64-darwin = fetchurl {
      url = "https://files.radicle.xyz/${versionCommit}/aarch64-apple-darwin/radicle-aarch64-apple-darwin.tar.gz";
      sha256 = "sha256-Zi8ycefDYeY871SqH+KflPv613vTl+RgfXtheOeOWsY=";
    };
  }).${stdenv.hostPlatform.system};

  installPhase = ''
    mkdir -p $out/bin
    mv -v * $out/bin
  '';

  meta = with lib; {
    description = "A decentralized app for code collaboration (binary release)";
    homepage = "https://radicle.xyz/";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ ];
    platforms = [
      "x86_64-linux"
      "x86_64-darwin"
      "aarch64-linux"
      "aarch64-darwin"
    ];
  };
}
