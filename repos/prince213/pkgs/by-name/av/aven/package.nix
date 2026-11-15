{
  lib,
  fetchFromGitHub,
  rustPlatform,
  stdenv,

  # nativeBuildInputs
  darwin,
  installShellFiles,
  makeBinaryWrapper,
  pkg-config,
  re-plistbuddy,

  # buildInputs
  aws-lc,
  sqlite,
  zstd,

  # nativeInstallCheckInputs
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "aven";
  version = "0.1.56";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "raine";
    repo = "aven";
    tag = "v${finalAttrs.version}";
    hash = "sha256-1If2URNOXgKxyisXqGLxCmeBF7n5BY7MOh35eLc6dz8=";
  };

  cargoHash = "sha256-pyOxHreqeO4fDI7pL6UjctOZhLayYQuCDpKIV5H4ILo=";

  nativeBuildInputs = [
    installShellFiles
    pkg-config
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    darwin.autoSignDarwinBinariesHook
    makeBinaryWrapper
    re-plistbuddy
  ];

  buildInputs = [
    aws-lc
    sqlite
    zstd
  ];

  doCheck = false;

  postInstall =
    lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
      installShellCompletion --cmd aven \
        --bash <($out/bin/aven completions bash) \
        --fish <($out/bin/aven completions fish) \
        --zsh <($out/bin/aven completions zsh)
    ''
    + lib.optionalString stdenv.hostPlatform.isDarwin ''
      mkdir -p $out/Applications/Aven.app/Contents
      cp macos/Info.plist $out/Applications/Aven.app/Contents/
      plutil -insert CFBundleShortVersionString -string ${finalAttrs.version} $out/Applications/Aven.app/Contents/Info.plist
      plutil -insert CFBundleVersion -string ${finalAttrs.version} $out/Applications/Aven.app/Contents/Info.plist

      mkdir -p $out/Applications/Aven.app/Contents/MacOS
      mv $out/bin/aven $out/Applications/Aven.app/Contents/MacOS/aven
      makeWrapper $out/Applications/Aven.app/Contents/MacOS/aven $out/bin/aven

      mkdir -p $out/Applications/Aven.app/Contents/Resources
      cp macos/Resources/{Assets.car,Aven.icns} $out/Applications/Aven.app/Contents/Resources/
    '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  meta = {
    description = "Local-first task manager for power users and agents";
    homepage = "https://aventasks.dev/";
    downloadPage = "https://github.com/raine/aven/releases";
    changelog = "https://github.com/raine/aven/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ prince213 ];
    mainProgram = "aven";
    mainDarwinApp = "Aven.app";
  };
})
