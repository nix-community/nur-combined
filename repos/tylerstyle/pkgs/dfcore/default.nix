{
  lib,
  rustPlatform,
  fetchFromGitHub,
  makeWrapper,
  util-linux,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "dfcore";
  version = "0.1.0";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "tylerstyle";
    repo = "dfcore";
    tag = "v${finalAttrs.version}";
    hash = "sha256-mzwV620LnaWlUM9PawWg3pg04U6FrvAfk9VGyjFC0Ek=";
  };

  cargoHash = "sha256-Guwa4LeVfToS+uyw8t+qCqUQfM+qn5Vz9IgSZSyHSXo=";

  nativeBuildInputs = [ makeWrapper ];

  postInstall = ''
    # dfcore-protect reads the device tree with lsblk
    wrapProgram $out/bin/dfcore-protect \
      --prefix PATH : ${lib.makeBinPath [ util-linux ]}
  '';

  meta = {
    description = "Shared forensic safety core for dfnix tools (device topology, protected-device registry, audit log)";
    homepage = "https://github.com/tylerstyle/dfcore";
    changelog = "https://github.com/tylerstyle/dfcore/releases/tag/${finalAttrs.src.tag}";
    license = with lib.licenses; [ mit asl20 ];
    maintainers = with lib.maintainers; [ ] ++ lib.optionals (lib.maintainers ? tylerstyle) [ lib.maintainers.tylerstyle ];
    mainProgram = "dfcore-audit";
    platforms = lib.platforms.linux;
  };
})
