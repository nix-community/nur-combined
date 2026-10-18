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
  version = "0-unstable-2026-10-18";

  src = fetchFromGitHub {
    owner = "merrkry";
    repo = "yaasm";
    rev = "069a7254ea91727d578dcb9204336900fc1ad65f";
    hash = "sha256-5oRS92d9bo/A6VYwV/Hf8vjKe/RGQBR5XpnmtaeOofA=";
  };

  cargoHash = "sha256-YdG/L18KSyjv2Q52WzS5ixXFl3mRe3gA2WoYLKF+Gx4=";

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
