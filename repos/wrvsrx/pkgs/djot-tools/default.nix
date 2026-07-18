{
  fetchFromGitHub,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "djot-tools";
  version = "0.21.2";

  src = fetchFromGitHub {
    owner = "wrvsrx";
    repo = "djot-tools";
    tag = finalAttrs.version;
    hash = "sha256-ft69GPT+0DVBjQLtvDl3H0BdvpriydLO89P0fkKrKmE=";
  };

  cargoHash = "sha256-yJ7iLFwEec39r2Ox/anVpSefyRsrEieCg63LpYCVVU0=";

  postInstall = ''
    mkdir -p $out/share/djot-tools
    cp -r skills $out/share/djot-tools/
  '';
})
