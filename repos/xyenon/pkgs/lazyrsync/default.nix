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
  version = "0.2.0";
  src = fetchFromGitHub {
    owner = "westpoint-io";
    repo = "lazyrsync";
    rev = "v${finalAttrs.version}";
    hash = "sha256-GKTHohpA9h+uqJS2dwgjMmGfl3KRbmE9Jt94YbprVKE=";
  };

  cargoHash = "sha256-OE7TCcPRDqbtVXN/VDO4HckM6woV/0gzfNr8Di+m1Oo=";

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
