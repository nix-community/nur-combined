{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  java,
  makeWrapper,
}:

buildNpmPackage rec {
  pname = "npm-groovy-lint";
  version = "15.2.2";

  src = fetchFromGitHub {
    owner = "nvuillam";
    repo = "npm-groovy-lint";
    tag = "v${version}";
    hash = "sha256-KrUfIDpe7HTla3Umx4aIaLpI5fJ+hLjq8YYH2Y0iKk0=";
  };

  npmDepsHash = "sha256-WgqjScJ+dOLNt2asd+3MnWjOesyOxm8CLMMWvJWaUHw=";

  nativeBuildInputs = [ makeWrapper ];

  preFixup = ''
    wrapProgram "$out/bin/npm-groovy-lint" --prefix PATH : "${lib.makeBinPath [ java ]}"
  '';

  meta = {
    description = "Lint, format and auto-fix your Groovy/Jenkinsfile/Gradle files using command line";
    homepage = "https://nvuillam.github.io/npm-groovy-lint/";
    changelog = "https://github.com/nvuillam/npm-groovy-lint/releases/tag/${src.rev}";
    license = lib.licenses.gpl3Plus;
    mainProgram = "npm-groovy-lint";
  };
}
