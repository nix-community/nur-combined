{ lib
, buildNpmPackage
, fetchFromGitHub
}:

buildNpmPackage rec {
  pname = "npm-groovy-lint";
  version = "13.0.1";

  src = fetchFromGitHub {
    owner = "nvuillam";
    repo = "npm-groovy-lint";
    rev = "v${version}";
    hash = "sha256-tFQw906hkNtXRN0uLYHMJMlAlE+VkTYOk+cETNJH3TY=";
  };

  postPatch = ''
    cp ${./package-lock.json} ./package-lock.json
  '';

  npmDepsHash = "sha256-fUqRKtrfMwFubfs+y0+QRtY/icQCoXjNFJY2UuKo9ps=";

  meta = {
    description = "Lint, format and auto-fix your Groovy/Jenkinsfile/Gradle files using command line";
    homepage = "https://nvuillam.github.io/npm-groovy-lint/";
    changelog = "https://github.com/nvuillam/npm-groovy-lint/releases/tag/${src.rev}";
    license = lib.licenses.gpl3Plus;
    mainProgram = "npm-groovy-lint";
    maintainers = with lib.maintainers; [ wolfangaukang ];
  };
}
