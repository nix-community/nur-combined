{
  stdenv,
  fetchFromGitHub,
  gnumake,
  asciidoctor,
  ...
}
:
stdenv.mkDerivation rec {
  pname = "tty-copy";
  version = "0.2.2";

  src = fetchFromGitHub {
    owner = "jirutka";
    repo = "tty-copy";
    rev = "v${version}";
    sha256 = "sha256-cKPAs91oIAusBn+210b3OSWySZfKc+9KJBlQc2AmXuo=";
  };

  nativeBuildInputs = [
    gnumake
    stdenv.cc
    asciidoctor
  ];

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/share/man/man1

    install -m755 build/tty-copy $out/bin
    install -m644 build/tty-copy.1 $out/share/man/man1/tty-copy.1
  '';
}
