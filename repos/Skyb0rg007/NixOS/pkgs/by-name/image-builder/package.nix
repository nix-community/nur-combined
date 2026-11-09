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
  version = "90.0.0";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "osbuild";
    repo = "image-builder";
    tag = "v${finalAttrs.version}";
    hash = "sha256-jH/CnQfs7DDEvX67g8M9WJx+zTqSw5f8TRVVkVfg+Hw=";
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

  vendorHash = "sha256-PA9U6Y8wLqPlz5CgqKZzFB0ENfTlP610YxsYssY36mk=";

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
