{
  lib,
  buildGoModule,
  fetchFromGitHub,
  stdenv,
  btrfs-progs,
  gpgme,
  libvirt,
  libxcrypt,
  linuxHeaders,
  krb5,
  pkg-config,
  nix-update-script,
}:
buildGoModule (finalAttrs: {
  pname = "image-builder";
  version = "83.0.0";

  src = fetchFromGitHub {
    owner = "osbuild";
    repo = "image-builder";
    tag = "v${finalAttrs.version}";
    hash = "sha256-T0TULbWTWhWf0h1QdMYOBtrHOG4q2FFNZeh9Z/8CUbU=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [
    btrfs-progs
    gpgme
    libxcrypt
    libvirt
    linuxHeaders
    krb5
  ];

  vendorHash = "sha256-cmmewEmLpXEZMLobM0c60Ar9AEmfb5IIKJKtBYL8t78=";

  doCheck = false;

  # postPatch = ''
  #   substituteInPlace internal/testutil/testutil.go \
  #     --replace-fail '#!/bin/bash' "#!${stdenv.shell}"
  # '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Tools to build and deploy disk-images";
    mainProgram = "image-builder";
    homepage = "https://osbuild.org";
    downloadPage = "https://github.com/osbuild/image-builder";
    changelog = "https://github.com/osbuild/image-builder/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    platforms = lib.platforms.linux;
    maintainers = [ lib.maintainers.skyesoss ];
  };
})
