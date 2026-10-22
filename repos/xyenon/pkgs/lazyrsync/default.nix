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
  version = "0.4.0";
  src = fetchFromGitHub {
    owner = "westpoint-io";
    repo = "lazyrsync";
    rev = "v${finalAttrs.version}";
    hash = "sha256-v4/UvglfXHmTmotK3wb0czKHyTJbWiDb6uxMuBmkwIo=";
  };

  cargoHash = "sha256-FP5zPyt961m5xCuWdXoYLYcj8vP01X6IgFlDqnhHpOk=";

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
