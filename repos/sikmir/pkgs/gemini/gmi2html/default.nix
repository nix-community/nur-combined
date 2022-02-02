{ lib, stdenv, fetchFromGitHub, zig, scdoc, installShellFiles }:

stdenv.mkDerivation rec {
  pname = "gmi2html";
  version = "2022-01-03";

  src = fetchFromGitHub {
    owner = "shtanton";
    repo = pname;
    rev = "2ee16d29c2ffd4057f2e89efb0d323ef79c70010";
    hash = "sha256-wlFj/zymZgG8vaY9yUs4NmV+CCMsjgchCyNDvgqZTLk=";
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
