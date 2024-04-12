{ lib
, buildNpmPackage
, fetchFromGitHub
}:

buildNpmPackage {
  pname = "nexe";
  version = "5.0.0-unstable-2023-11-17";

  src = fetchFromGitHub {
    owner = "nexe";
    repo = "nexe";
    rev = "175bbf13fe2e58f12f018d48fd62fe0f801921b0";
    hash = "sha256-K4/4Azbg7vsltnlAi1d8ZY0i0q9wCFllyauHOnPaBFM=";
  };

  npmDepsHash = "sha256-Nct9qWvwjRjhigcSUO+VgkwYwl1FZKFD38HxaLWRy64=";

  meta = {
    description = "Create a single executable out of your node.js apps";
    changelog = "https://github.com/nexe/nexe/blob/master/CHANGELOG.md";
    homepage = "https://github.com/nexe/nexe";
    licenses = lib.licenses.mit;
    mainProgram = "nexe";
    maintainers = with lib.maintainers; [ wolfangaukang ];
  };
}
