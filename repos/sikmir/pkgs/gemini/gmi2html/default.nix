{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  zig_0_14,
  scdoc,
  installShellFiles,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gmi2html";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "shtanton";
    repo = "gmi2html";
    tag = "v${finalAttrs.version}";
    hash = "sha256-J71QThRwV8lpGJndqVT+tsekO+CVU8piSpjAn9jwfDI=";
  };

  patches = [
    # Patch for compatability with zig 0.14.0
    (fetchpatch {
      url = "https://github.com/shtanton/gmi2html/pull/25/commits/29750dd364167db1b463cd5d29fc90519f293f0c.patch";
      hash = "sha256-Z6Go9uUINadvegrVoCLXNeLtwXLzJZs7CeiyfpdAJ1k=";
    })
  ];

  nativeBuildInputs = [
    zig_0_14.hook
    scdoc
    installShellFiles
  ];

  postBuild = ''
    scdoc < doc/gmi2html.scdoc > doc/gmi2html.1
  '';

  doCheck = true;

  checkPhase = ''
    sh tests/test.sh
  '';

  postInstall = ''
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
