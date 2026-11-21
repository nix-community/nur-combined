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
  version = "0-unstable-2026-11-21";

  src = fetchFromGitHub {
    owner = "merrkry";
    repo = "yaasm";
    rev = "bbba889982f2fff5d35ece41f3aed15b945dfcc5";
    hash = "sha256-lrC1Ith5lYQtdRlTjxIRrfteW+HPOSbJy9P9A834I60=";
  };

  cargoHash = "sha256-v9wqVVxdGGIueS5yzdsQPH0HrFkC+iUdFQKGiuh1iII=";

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
