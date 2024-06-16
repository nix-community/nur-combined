{
  lib,
  stdenv,
  fetchFromGitHub,
  zig,
  scdoc,
  installShellFiles,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gmi2html";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "shtanton";
    repo = "gmi2html";
    rev = "v${finalAttrs.version}";
    hash = "sha256-J71QThRwV8lpGJndqVT+tsekO+CVU8piSpjAn9jwfDI=";
  };

  nativeBuildInputs = [
    zig
    scdoc
    installShellFiles
  ];

  buildPhase = ''
    export HOME=$TMPDIR
    zig build -Drelease-small=true -Dcpu=baseline
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

  meta = {
    description = "Translate text/gemini into HTML";
    homepage = "https://github.com/shtanton/gmi2html";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
})
