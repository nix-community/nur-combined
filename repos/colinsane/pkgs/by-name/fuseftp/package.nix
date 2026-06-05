{
  fetchFromCodeberg,
  lib,
  makeBinaryWrapper,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
  util-linux,
}:
rustPlatform.buildRustPackage {
  pname = "fuseftp";
  version = "0.1.0-unstable-2026-03-03";

  src = fetchFromCodeberg {
    owner = "nettika";
    repo = "fuseftp";
    rev = "2383163c7ac6a2341762d8b986e0b79ae1681a4b";
    hash = "sha256-e2OgiB+g4d8c3mlTi9xVQgyYw62RGfR725C2QYxVgs8=";
  };

  cargoHash = "sha256-fByvf6ypfkWDTZoXxCF8ovsDN9CggNTblV3rYq4dKu4=";

  nativeBuildInputs = [
    makeBinaryWrapper
    pkg-config
  ];

  buildInputs = [
    openssl
  ];

  postInstall = ''
    wrapProgram $out/bin/mount_fuse_ftp --prefix PATH : $out/bin
    ln -s $out/bin/mount_fuse_ftp $out/bin/mount.fuse.ftp
    makeWrapper ${lib.getExe' util-linux "setsid"} $out/bin/mount.fuse.ftp-daemon \
      --add-flags "-f $out/bin/mount.fuse.ftp"
    install -Dm644 man/mount.fuse.ftp.8 $out/share/man/man8/mount.fuse.ftp.8
  '';

  # checkFlags = [
  #   "--skip=test_connection"
  #   "--skip=test_lookup::*"
  # ];

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version" "branch" ];
  };

  meta = {
    description = "Mount an FTP filesystem using FUSE";
    homepage = "https://codeberg.org/nettika/fuseftp";
    maintainers = with lib.maintainers; [ colinsane ];
    mainProgram = "fuseftp";
  };
}
