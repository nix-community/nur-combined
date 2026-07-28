# modified from <nixpkgs>/pkgs/by-name/du/dufs/package.nix
{
  lib,
  rustPlatform,
  fetchFromGitHub,
  installShellFiles,
  stdenv,
  cacert,
}:

rustPlatform.buildRustPackage rec {
  pname = "dufs";
  version = "0.46.0-unstable-2026-02-05";

  src = fetchFromGitHub {
    owner = "sigoden";
    repo = "dufs";
    rev = "a118c1348e07bf8312e2ea5b7edabd3b2dca0e11";
    hash = "sha256-Pkugd+Zz7hnVTWu7c0HlAoztuOEBzAt3IWI8572Eo38=";
  };

  cargoHash = "sha256-+MEEyHNc9hRfF8N9JHrF109Z9H2/4aQR6CNhgwdFiq0=";

  env.SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";

  nativeBuildInputs = [ installShellFiles ];

  __darwinAllowLocalNetworking = true;

  checkFlags = [
    # tests depend on network interface, may fail with virtual IPs.
    "--skip=validate_printed_urls,auth_check2"
  ];

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd dufs \
      --bash <($out/bin/dufs --completions bash) \
      --fish <($out/bin/dufs --completions fish) \
      --zsh <($out/bin/dufs --completions zsh)
  '';

  meta = with lib; {
    description = "File server that supports static serving, uploading, searching, accessing control, webdav";
    mainProgram = "dufs";
    homepage = "https://github.com/sigoden/dufs";
    changelog = "https://github.com/sigoden/dufs/blob/${src.rev}/CHANGELOG.md";
    license = with licenses; [
      asl20 # or
      mit
    ];
  };
}
