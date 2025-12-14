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
          url = "https://github.com/TheColorman/Anchorr/commit/d74d53292c1cc99d61f1390af559f6dd5c0bd48c.patch";
          hash = "sha256-U2mwjIr1adja/uqUbxv3LBvH01noUQBV3sR8312kubM=";
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
