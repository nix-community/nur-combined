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
  version = "0.3.0";
  src = fetchFromGitHub {
    owner = "westpoint-io";
    repo = "lazyrsync";
    rev = "v${finalAttrs.version}";
    hash = "sha256-cM6FBNXSDOcPkAxf8gNtjaHl1mR7tH383zFIQlPj+GE=";
  };

  cargoHash = "sha256-Qzy9N0km9kw+deg2tfFyffnTrLyuPWRS2yqmuX3CZrQ=";

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
