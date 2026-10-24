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
  zstd,

  # nativeInstallCheckInputs
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "aven";
  version = "0.1.51";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "raine";
    repo = "aven";
    tag = "v${finalAttrs.version}";
    hash = "sha256-vARyE3x8lMfpy31Ue7VAkTB95FLKvH6+bOyADIMZxbw=";
  };

  cargoHash = "sha256-kY6vzkBZ5zTrQGXGFkd2cqflr8Px6oTGYOJgDL8vTR8=";

  nativeBuildInputs = [
    installShellFiles
    pkg-config
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    darwin.autoSignDarwinBinariesHook
    makeBinaryWrapper
    re-plistbuddy
  ];

  buildInputs = [ zstd ];

  env = {
    ZSTD_SYS_USE_PKG_CONFIG = 1;
  };

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
