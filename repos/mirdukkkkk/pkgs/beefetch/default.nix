{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  installShellFiles,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "beefetch";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "mirdukkkkk";
    repo = "beefetch";
    tag = finalAttrs.version;
    hash = "sha256-s9GCgheuseHkw0oLJ2Am5XYm+RmCDz34jJwrDxcvbKE=";
  };

  cargoHash = "sha256-yYNuFFqPoMy0tNGZOU/tXVzK6pVWbxiRsjalKAHERVI=";

  nativeBuildInputs = [ installShellFiles ];

  postInstall = ''
    installManPage docs/beefetch.1
  ''
  + lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd beefetch \
      --bash <($out/bin/beefetch --bpaf-complete-style-bash) \
      --fish <($out/bin/beefetch --bpaf-complete-style-fish) \
      --zsh <($out/bin/beefetch --bpaf-complete-style-zsh)
  '';

  meta = {
    description = "Neofetch clone written in Rust with the ability to display 🐝";
    homepage = "https://github.com/mirdukkkkk/beefetch";
    license = lib.licenses.gpl3Only;
    mainProgram = "beefetch";
    platforms = lib.platforms.linux;
  };
})
