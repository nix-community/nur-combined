# modified from <nixpkgs>/pkgs/by-name/du/dufs/package.nix
{
  lib,
  rustPlatform,
  fetchFromGitHub,
  installShellFiles,
  stdenv,
}:

rustPlatform.buildRustPackage rec {
  pname = "dufs";
  version = "0.45.0-unstable-2025-09-04";

  src = fetchFromGitHub {
    owner = "sigoden";
    repo = "dufs";
    rev = "23619033ae308e5a60494704be0e51c481a0d03c";
    hash = "sha256-83lFnT4eRYaBe4e2o6l6AGQycm/oK96n5DXutBNvBsE=";
  };

  patches = [ ./fix-sort.patch ];

  cargoHash = "sha256-WdjqG2URtloh5OnpBBnEWHD3WKGkCKLDcCyWRVGIXto=";

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
