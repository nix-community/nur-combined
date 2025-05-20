{
  lib,
  stdenv,
  pkgs,
  fetchFromGitHub,
}:
let 
  
  hasRustNightly = pkgs ? rust-bin;

  rustPlatform = if hasRustNightly then
    pkgs.makeRustPlatform {
            cargo = pkgs.rust-bin.nightly.latest.minimal;
            rustc = pkgs.rust-bin.nightly.latest.minimal;
          }
  else
    pkgs.rustPlatform;
in 

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "microsoft-edit";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "microsoft";
    repo = "edit";
    tag = "v${finalAttrs.version}";
    hash = "sha256-5GUAHa0/7k4uVNWEjn0hd1YvkRnUk6AdxTQhw5z95BY=";
  };

  # nativeBuildInputs = [
  #   installShellFiles
  #   makeWrapper
  #   pkg-config
  # ];

  cargoHash = "sha256-DEzjfrXSmum/GJdYanaRDKxG4+eNPWf5echLhStxcIg=";

  # # maa-cli would only search libMaaCore.so and resources in itself's path
  # # https://github.com/MaaAssistantArknights/maa-cli/issues/67
  # postInstall =
  #   ''
  #     mkdir -p $out/share/maa-assistant-arknights/
  #     ln -s ${maa-assistant-arknights}/share/maa-assistant-arknights/* $out/share/maa-assistant-arknights/
  #     ln -s ${maa-assistant-arknights}/lib/* $out/share/maa-assistant-arknights/
  #     mv $out/bin/maa $out/share/maa-assistant-arknights/

  #     makeWrapper $out/share/maa-assistant-arknights/maa $out/bin/maa \
  #       --prefix PATH : "${
  #         lib.makeBinPath [
  #           android-tools
  #           git
  #         ]
  #       }"

  #   ''
  #   + lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
  #     installShellCompletion --cmd maa \
  #       --bash <($out/bin/maa complete bash) \
  #       --fish <($out/bin/maa complete fish) \
  #       --zsh <($out/bin/maa complete zsh)

  #     mkdir -p manpage
  #     $out/bin/maa mangen --path manpage
  #     installManPage manpage/*
  #   '';

  meta = with lib; {
    description = "MS-DOS style terminal editor";
    homepage = "https://github.com/microsoft/edit";
    license = licenses.mit;
    platforms = platforms.unix;
    maintainers = with maintainers; [ Cryolitia ];
    mainProgram = "edit";
  };
})
