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
    rev = "e954aebd0a89510c5c581c7578c1d4761bac681e";
    hash = "sha256-6ASQZWrmSqFr5RhMee14PfaHGzZ/4yLTtbfBEIpjDws=";
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
