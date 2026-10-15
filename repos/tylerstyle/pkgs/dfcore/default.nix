{
  lib,
  rustPlatform,
  fetchFromGitHub,
  makeWrapper,
  util-linux,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "dfcore";
  version = "0.2.0";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "tylerstyle";
    repo = "dfcore";
    tag = "v${finalAttrs.version}";
    hash = "sha256-CUcFeUqfEKERS9RU9Y039uP/1MAeMXiKRkIWgfiClLU=";
  };

  cargoHash = "sha256-Fkh9CUtXSy2maHsV5QFwPaV7a9+EQNEihgX62Mgcf2o=";

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
