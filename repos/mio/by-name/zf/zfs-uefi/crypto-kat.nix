# Known-answer tests for the AES-256-GCM code that the ZFS boot reader needs to
# unwrap dataset keys and read encrypted blocks.
#
# This is a separate derivation from zfs-uefi on purpose: it compiles the same
# sources for the host, so a wrong S-box or GHASH bit order fails here in
# seconds instead of showing up as "all block copies unavailable" in the VM.
# Built with -ffreestanding -fno-builtin to keep the sources honest about what
# they can use inside the EFI image (no libc).
{ stdenv }:
stdenv.mkDerivation {
  pname = "zfs-uefi-crypto-kat";
  version = "0";

  src = ./crypto;
  dontConfigure = true;

  buildPhase = ''
    runHook preBuild
    $CC -O2 -std=c11 -Wall -Wextra -Werror -ffreestanding -fno-builtin \
      -o kat aesgcm.c sha512.c sha1.c kat.c
    ./kat
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 kat $out/bin/zfs-uefi-crypto-kat
    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    "$out/bin/zfs-uefi-crypto-kat"
    runHook postInstallCheck
  '';

  meta.description = "Known-answer tests for the zfs-uefi AES-256-GCM code";
}
