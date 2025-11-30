{
  lib,
  stdenv,
  nodejs,
  fetchurl,
  installShellFiles,
  makeBinaryWrapper,
  versionCheckHook,
}:
stdenv.mkDerivation rec {
  pname = "prettier-inogai";
  version = "1.0.0-3.7.0.dev";

  src = fetchurl {
    url = "https://registry.npmjs.org/@inogai/prettier/-/prettier-${version}.tgz";
    hash = "sha512-BgdWIBb7NzcMXkak4PMRgifCd0+6T+CHBWmNgnY4ZLAV2jfRiJ7cUiLu7JbCEJGxZ2d+Ziynu6//WwxBE22SSw==";
  };

  nativeBuildInputs = [
    installShellFiles
    makeBinaryWrapper
  ];

  sourceRoot = "package";

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/node_modules
    cp --recursive . "$out/lib/node_modules/prettier-inogai"

    makeBinaryWrapper "${lib.getExe nodejs}" "$out/bin/prettier-inogai" \
      --add-flags "$out/lib/node_modules/prettier-inogai/bin/prettier.cjs"

    runHook postInstall
  '';

  postInstall = ''
    # Install man pages if they exist
    if [ -d "$out/lib/node_modules/prettier-inogai/man" ]; then
      installManPage $out/lib/node_modules/prettier-inogai/man/*
    fi
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = "--version";

  meta = {
    description = "Prettier is an opinionated code formatter (inogai fork)";
    homepage = "https://www.github.com/inogai/prettier";
    changelog = "https://github.com/inogai/prettier/releases";
    license = lib.licenses.mit;
    maintainers = [lib.maintainers.inogai];
    mainProgram = "prettier-inogai";
    platforms = lib.platforms.all;
  };
}

