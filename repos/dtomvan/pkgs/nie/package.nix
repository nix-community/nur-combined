{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitea,
  nix,
  makeWrapper,
  installShellFiles,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "nie";
  version = "0.1.3";

  outputs = [
    "out"
    "man"
  ];

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "jzbor";
    repo = "nie";
    tag = "v${finalAttrs.version}";
    hash = "sha256-HVuRSM5hle/tu45PnGldHH9bvzoZYxrVNXToGfYiwEE=";
  };

  nativeBuildInputs = [
    makeWrapper
    installShellFiles
  ];

  cargoHash = "sha256-itQVMXvUJq4n5ips/dIm0oWGyEAfVIBIMlUbQ4VXGjo=";

  postInstall = ''
    mkdir manpages completions
    $out/bin/nie man manpages
    $out/bin/nie completions completions
    installManPage manpages/*
  ''
  + lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion completions/nie.{bash,fish,zsh}
  '';

  postFixup = ''
    wrapProgram $out/bin/nie \
      --prefix PATH ${lib.makeBinPath [ nix ]}
  '';

  meta = {
    description = "Nix wrapper with flake-compat builtin";
    homepage = "https://codeberg.org/jzbor/nie";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dtomvan ];
    mainProgram = "nie";
  };
})
