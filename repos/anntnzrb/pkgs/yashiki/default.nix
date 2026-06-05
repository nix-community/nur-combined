{
  lib,
  rustPlatform,
  fetchFromGitHub,
  installShellFiles,
  apple-sdk_15,
}:

rustPlatform.buildRustPackage rec {
  pname = "yashiki";
  version = "0.14.0";

  src = fetchFromGitHub {
    owner = "typester";
    repo = "yashiki";
    rev = "yashiki-v${version}";
    hash = "sha256-ePZ8ONdvj3gaQps+5Ua0OLeFdzNdJhoB9yw6pC7qoEQ=";
  };

  cargoHash = "sha256-JMrftBKyD188SZqEGI4fA/MrfEK8JLKSeEqrQxhSs3U=";

  nativeBuildInputs = [
    installShellFiles
  ];

  buildInputs = [
    apple-sdk_15
  ];

  postInstall = ''
    app="$out/Applications/Yashiki.app"

    mkdir -p "$app/Contents/MacOS" "$app/Contents/Resources/layouts"

    ln -s "$out/bin/yashiki" "$app/Contents/MacOS/yashiki"
    ln -s "$out/bin/yashiki-layout-tatami" "$app/Contents/Resources/layouts/yashiki-layout-tatami"
    ln -s "$out/bin/yashiki-layout-byobu" "$app/Contents/Resources/layouts/yashiki-layout-byobu"

    cp resources/icon/Assets.car "$app/Contents/Resources/Assets.car"
    substitute Info.plist.template "$app/Contents/Info.plist" \
      --replace-fail VERSION_PLACEHOLDER "${version}" \
      --replace-fail "<string>yashiki-launcher</string>" "<string>yashiki</string>"

    installShellCompletion --cmd yashiki --zsh completions/zsh/_yashiki
  '';

  meta = {
    description = "macOS tiling window manager";
    homepage = "https://github.com/typester/yashiki";
    changelog = "https://github.com/typester/yashiki/releases/tag/yashiki-v${version}";
    license = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
    maintainers = [
      {
        name = "anntnzrb";
        github = "anntnzrb";
        githubId = 51257127;
      }
    ];
    mainProgram = "yashiki";
    platforms = lib.platforms.darwin;
  };
}
