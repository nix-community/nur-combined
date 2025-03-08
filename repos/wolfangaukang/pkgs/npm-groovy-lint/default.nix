{ lib
, buildNpmPackage
, fetchFromGitHub
}:

buildNpmPackage rec {
  pname = "npm-groovy-lint";
  version = "15.1.0";

  src = fetchFromGitHub {
    owner = "nvuillam";
    repo = "npm-groovy-lint";
    rev = "v${version}";
    hash = "sha256-BLR709MCzq3t9+7v4vfBzojd0tARG/pvhCxob5A7Xxk=";
  };

  npmDepsHash = "sha256-qvao/iJ3njcdrEXsH3jgNh0LuaAPrO2bLVOeiUdTwVM=";

  meta = {
    description = "Lint, format and auto-fix your Groovy/Jenkinsfile/Gradle files using command line";
    homepage = "https://nvuillam.github.io/npm-groovy-lint/";
    changelog = "https://github.com/nvuillam/npm-groovy-lint/releases/tag/${src.rev}";
    license = lib.licenses.gpl3Plus;
    mainProgram = "npm-groovy-lint";
  };
}
