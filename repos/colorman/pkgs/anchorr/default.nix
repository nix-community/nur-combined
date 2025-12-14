{
  buildNpmPackage,
  fetchFromGitHub,
  nodejs,
}: let
  version = "v1.3.4";
in
  buildNpmPackage {
    inherit version;

    pname = "anchorr";

    src = fetchFromGitHub {
      owner = "nairdahh";
      repo = "Anchorr";
      tag = version;
      hash = "sha256-+gGh/ID9UWYwRXHOJ8S1gafpsddipFIT5fqYql4aPEQ=";
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
