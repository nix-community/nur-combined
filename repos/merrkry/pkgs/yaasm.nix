{
  fetchFromGitHub,
  git,
  lib,
  makeWrapper,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  __structuredAttrs = true;

  pname = "yaasm";
  version = "0-unstable-2026-09-05";

  src = fetchFromGitHub {
    owner = "merrkry";
    repo = "yaasm";
    rev = "9ff8e98a04373b92c235c03356ced1f87806c2c9";
    hash = "sha256-TxWW7/vyeYT3H6Bghb72usQRYjUGQTjEFZEhIt08I0A=";
  };

  cargoHash = "sha256-WDPpCFU5186p1UEdjdnshdVJ4vdHbf7sRYbT9R5i9lY=";

  strictDeps = true;
  nativeBuildInputs = [ makeWrapper ];
  nativeCheckInputs = [ git ];

  postInstall = ''
    wrapProgram $out/bin/yaasm --prefix PATH : ${lib.makeBinPath [ git ]}
  '';

  meta = {
    description = "Yet another agent skills manager";
    homepage = "https://github.com/merrkry/yaasm";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ merrkry ];
    mainProgram = "yaasm";
  };
})
