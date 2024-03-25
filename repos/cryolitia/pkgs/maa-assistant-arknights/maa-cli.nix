{ lib
, stdenv
, rustPlatform
, fetchFromGitHub
, makeWrapper
, pkg-config
, openssl
, maa-assistant-arknights
, android-tools
, git
}:

rustPlatform.buildRustPackage rec {
  pname = "maa-cli";
  version = "0.4.4";

  src = fetchFromGitHub {
    owner = "MaaAssistantArknights";
    repo = "maa-cli";
    rev = "v${version}";
    hash = "sha256-pAtv6gCLFKRwUQEF6kD2bCPGpQGzahsfq/tAnQjrZrw=";
  };

  nativeBuildInputs = [
    makeWrapper
    pkg-config
  ];

  buildInputs = [
    openssl
  ];

  # https://github.com/MaaAssistantArknights/maa-cli/pull/126
  buildNoDefaultFeatures = true;
  buildFeatures = [ "git2" "core_installer" ];

  cargoHash = "sha256-KjI/5vl7oKVtXYehGLgi9jcaO4Y/TceL498rCPGHMD0=";

  # maa-cli would only seach libMaaCore.so and resources in itself's path
  # https://github.com/MaaAssistantArknights/maa-cli/issues/67
  postInstall = ''
    mkdir -p $out/share/maa-assistant-arknights/
    ln -s ${maa-assistant-arknights}/share/maa-assistant-arknights/* $out/share/maa-assistant-arknights/
    ln -s ${maa-assistant-arknights}/lib/* $out/share/maa-assistant-arknights/
    mv $out/bin/maa $out/share/maa-assistant-arknights/

    makeWrapper $out/share/maa-assistant-arknights/maa $out/bin/maa \
      --prefix PATH : "${lib.makeBinPath [
        android-tools git
      ]}"

    mkdir -p $out/share/zsh/site-functions/
    mkdir -p $out/share/bash-completion/completions/
    mkdir -p $out/share/fish/vendor_completions.d/
    $out/bin/maa complete zsh > $out/share/zsh/site-functions/_maa
    $out/bin/maa complete bash > $out/share/bash-completion/completions/maa.bash
    $out/bin/maa complete fish > $out/share/fish/vendor_completions.d/maa.fish
  '';

  meta = with lib; {
    description = "A simple CLI for MAA by Rust.";
    homepage = "https://github.com/MaaAssistantArknights/maa-cli";
    license = licenses.agpl3Plus;
    platforms = platforms.linux;
    maintainers = with maintainers; [ Cryolitia ];
    mainProgram = "maa";
  };
}
