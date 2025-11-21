{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
  makeWrapper,
  libayatana-appindicator,
  gtk3,
  pkg-config,
  stdenv,
  source,
}:
buildGoModule (finalAttrs: {

  pname = "kanata-tray";
  inherit (source) src version;

  vendorHash = "sha256-tW8NszrttoohW4jExWxI1sNxRqR8PaDztplIYiDoOP8=";

  env = {
    CGO_ENABLED = 1;
    GO111MODULE = "on";
    GOOS = if stdenv.hostPlatform.isDarwin then "darwin" else "linux";
  };

  flags = [ "-trimpath" ];

  ldflags = [
    "-s"
    "-w"
    "-X main.buildVersion=${finalAttrs.version}"
    "-X main.buildHash=${finalAttrs.src.rev}"
  ];
  nativeBuildInputs = lib.optionals stdenv.isLinux [ pkg-config ];
  buildInputs = [
    makeWrapper
  ]
  ++ (lib.optionals stdenv.isLinux [
    libayatana-appindicator
    gtk3
  ]);

  postInstall = ''
    wrapProgram $out/bin/kanata-tray --set-default KANATA_TRAY_LOG_DIR /tmp --prefix PATH : $out/bin
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Tray Icon for Kanata ";
    homepage = "https://github.com/rszyma/kanata-tray";
    changelog = "https://github.com/rszyma/kanata-tray/releases/tag/v${finalAttrs.version}";
    license = licenses.gpl3;
    maintainers = with maintainers; [ auscyber ];
    platforms = platforms.unix;
  };
})
