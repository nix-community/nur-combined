{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, openssl
, stdenv
, perl
, git
, makeWrapper
, nix-update-script
}:

rustPlatform.buildRustPackage rec {
  pname = "gitopolis";
  version = "1.17.2";

  src = fetchFromGitHub {
    owner = "timabell";
    repo = "gitopolis";
    rev = "v${version}";
    sha256 = "sha256-W74W1KjGaRH/X0GOLhfrMqOSP2IpBGORyc51Ko6M0ZI=";
  };

  cargoHash = "sha256-R4Lv8Y8xmS3fzLICTgjsfKDnIXEqnP4U59bUrItkXoE=";

  nativeBuildInputs = [
    pkg-config
    perl
    git # for testing
    makeWrapper
  ];

  buildInputs = [
    openssl
  ];

  postInstall = ''
    wrapProgram "$out/bin/gitopolis" \
      --prefix GIT_CONFIG_PARAMETERS " " "'color.ui=always'" \
      --argv0 "$out/bin/gitopolis"
  '';

  env.OPENSSL_NO_VENDOR = 1;

  doCheck = true;

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Manage multiple git repositories - CLI tool - run commands, clone, and organize repos with tags";
    homepage = "https://github.com/timabell/gitopolis";
    license = licenses.agpl3Only;
    maintainers = [ maintainers.bendlas ];
    platforms = platforms.all;
  };
}
