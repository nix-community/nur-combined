{ lib, stdenv, fetchFromGitHub, zig, scdoc, installShellFiles }:

stdenv.mkDerivation rec {
  pname = "gmi2html";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "shtanton";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-B0+1s2eB1SAaVkGqj9OupMg0wGJGPj86NMEN765e7OU=";
  };

  patches = [
    # https://github.com/shtanton/gmi2html/pull/12
    ./webp.patch
  ];

  nativeBuildInputs = [ zig scdoc installShellFiles ];

  preConfigure = "HOME=$TMP";

  buildPhase = ''
    zig build -Drelease-safe
    scdoc < doc/gmi2html.scdoc > doc/gmi2html.1
  '';

  doCheck = true;

  checkPhase = ''
    substituteInPlace tests/test.sh \
      --replace "zig-cache" "zig-out"
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
    broken = stdenv.isDarwin;
  };
}
