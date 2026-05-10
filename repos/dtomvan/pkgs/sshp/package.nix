{
  lib,
  stdenv,
  fetchFromGitHub,

  libtinfo,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sshp";
  version = "1.1.3";

  outputs = [
    "out"
    "man"
  ];
  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "bahamas10";
    repo = "sshp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-E7nt+t1CS51YG16371LEPtQxHTJ54Ak+r0LP0erC9Mk=";
  };

  postPatch = ''
    patchShebangs tools
  '';

  makeFlags = [ "PREFIX=${placeholder "out"}/share" ];

  doCheck = true;

  nativeCheckInputs = [ libtinfo ];

  # makefile assumes all directories exist already (cuz why won't they in an
  # FHS-compliant distro)
  preInstall = ''
    mkdir -p $out/share/{bin,man/man1}
  '';

  postInstall = ''
    moveToOutput share/man $man
    mv $out/share/bin $out/bin
    rmdir $out/share
  '';

  meta = {
    description = "Parallel SSH Executor";
    homepage = "https://github.com/bahamas10/sshp";
    changelog = "https://github.com/bahamas10/sshp/blob/${finalAttrs.src.rev}/CHANGES.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dtomvan ];
    mainProgram = "sshp";
    platforms = lib.platforms.all;
  };
})
