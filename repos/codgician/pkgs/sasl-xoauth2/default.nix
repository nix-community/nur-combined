{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  curl,
  cyrus_sasl,
  jsoncpp,
  pandoc,
  pkg-config,
  python3,
}:

let
  pythonEnv = python3.withPackages (
    ps: with ps; [
      argparse-manpage
      msal
    ]
  );
in
stdenv.mkDerivation rec {
  pname = "sasl-xoauth2";
  version = "0.25";

  src = fetchFromGitHub {
    owner = "tarickb";
    repo = "sasl-xoauth2";
    rev = "release-${version}";
    sha256 = "sha256-UYxVhKMH7JyGJ49rgEWptFsz8fGbA4DGjZeLgKnCXT4=";
  };

  nativeBuildInputs = [
    cmake
    curl
    pandoc
    pkg-config
    pythonEnv
  ];

  buildInputs = [
    cyrus_sasl
    jsoncpp
  ];

  fixupPhase = ''
    patchShebangs $out/bin
  '';

  meta = with lib; {
    homepage = "https://github.com/tarickb/sasl-xoauth2";
    description = "SASL plugin for XOAUTH2";
    platforms = platforms.unix;
    license = licenses.apsl20;
    maintainers = with lib.maintainers; [ codgician ];
  };
}
