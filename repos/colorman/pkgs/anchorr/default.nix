{
  buildNpmPackage,
  fetchFromGitHub,
  nodejs,
  applyPatches,
  fetchpatch,
}: let
  version = "v1.3.4";
in
  buildNpmPackage {
    inherit version;

    pname = "anchorr";

    src = applyPatches {
      src = fetchFromGitHub {
        owner = "nairdahh";
        repo = "Anchorr";
        tag = version;
        hash = "sha256-+gGh/ID9UWYwRXHOJ8S1gafpsddipFIT5fqYql4aPEQ=";
      };
      patches = [
        (fetchpatch {
          name = "dont-use-cwd";
          url = "https://github.com/TheColorman/Anchorr/commit/99deb47c090569326e1e2a13bbcd254db9394672.patch";
          hash = "sha256-Wx7BmuiJ47zAtRcPdgswOuR6FROvBcED/ABySw2uiAE=";
        })
      ];
    };

    postInstall = ''
      mkdir -p "$out/bin"

      # Create an executable wrapper
      makeWrapper ${nodejs}/bin/node "$out/bin/anchorr" \
        --add-flags "$out/lib/node_modules/anchorr/app.js"
    '';

    npmDepsHash = "sha256-2s2qvQrx+2rQakO2j3gVc6Yn1h7bMPZDmCHq7VoymdY=";

    dontNpmBuild = true;
  }
