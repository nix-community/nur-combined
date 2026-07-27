{
  lib,
  stdenv,
  fetchFromGitHub,
  vlang,
  git,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "v-analyzer";
  version = "0.0.6";

  src = fetchFromGitHub {
    owner = "vlang";
    repo = "v-analyzer";
    rev = "236d51bba1bccd57fd2950956fbffe5fe0248735";
    fetchSubmodules = true;
    hash = "sha256-F03iaRtGwFtn5gV/+s98TyX6CKzmIVYjnZgo5umArTw=";
  };

  nativeBuildInputs = [
    vlang
    git
  ];

  postPatch = ''
    # Remove static linking flag which requires glibc-static
    substituteInPlace build.vsh \
      --replace-fail '-cflags -static' ""
  '';

  preBuild = ''
    export HOME=$TMPDIR
  '';

  buildPhase = ''
    runHook preBuild
    v build.vsh release
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 bin/v-analyzer -t $out/bin
    runHook postInstall
  '';

  meta = {
    description = "Language server for the V programming language";
    longDescription = ''
      v-analyzer is a language server for the V programming language.
      It brings IDE capabilities to VS Code, Vim, and other editors by providing
      features like code completion, go to definition, find all references,
      and semantic syntax highlighting.
    '';
    homepage = "https://github.com/vlang/v-analyzer";
    changelog = "https://github.com/vlang/v-analyzer/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = [];
    platforms = lib.platforms.unix;
    mainProgram = "v-analyzer";
  };
})
