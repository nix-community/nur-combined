{
  lib,
  rustPlatform,
  fetchFromGitHub,
  rsync,
  makeWrapper,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  __structuredAttrs = true;

  pname = "lazyrsync";
  version = "0.1.1";
  src = fetchFromGitHub {
    owner = "westpoint-io";
    repo = "lazyrsync";
    rev = "v${finalAttrs.version}";
    hash = "sha256-JBELPmNSaiwxHq9iZHvvrCX/YLSBsOO3OrzXJ0mPrNw=";
  };

  cargoHash = "sha256-/L6N08TFqwW6yeNFiIUtmz6SxdEuxa6SHMxDoZ4Myl8=";

  nativeBuildInputs = [ makeWrapper ];

  postInstall = ''
    wrapProgram $out/bin/lazyrsync \
      --prefix PATH : ${lib.makeBinPath [ rsync ]}
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Terminal UI for rsync with profiles, dry-run preview, and live progress";
    homepage = "https://github.com/westpoint-io/lazyrsync";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ xyenon ];
    mainProgram = "lazyrsync";
  };
})
