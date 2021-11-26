{ lib, stdenv, fetchFromGitHub, zig, scdoc, installShellFiles }:

stdenv.mkDerivation rec {
  pname = "gmi2html";
  version = "2021-10-24";

  src = fetchFromGitHub {
    owner = "shtanton";
    repo = pname;
    rev = "5de5d162511aba10c32fe603af701f111b3a32ce";
    hash = "sha256-AYA2PWhowoSascD+jnLyXpLvxwZDGJiC8CvnN2tr+Ec=";
  };

  postPatch = ''
    substituteInPlace tests/test.sh \
      --replace "zig-cache" "zig-out"
  '';

  nativeBuildInputs = [ zig scdoc installShellFiles ];

  buildPhase = ''
    export HOME=$TMPDIR
    zig build -Drelease-safe=true
    scdoc < doc/gmi2html.scdoc > doc/gmi2html.1
  '';

  doCheck = true;

  checkPhase = ''
    sh tests/test.sh
  '';

  installPhase = ''
    zig build --prefix $out install
    installManPage doc/gmi2html.1
  '';

  meta = with lib; {
    description = "Translate text/gemini into HTML";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
    broken = stdenv.isDarwin; # https://github.com/NixOS/nixpkgs/issues/86299
  };
}
