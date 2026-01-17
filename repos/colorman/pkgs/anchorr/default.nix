{
  buildNpmPackage,
  fetchFromGitHub,
  nodejs,
  applyPatches,
}: let
  version = "v1.3.5";
in
  buildNpmPackage {
    inherit version;

    pname = "anchorr";

    src = applyPatches {
      src = fetchFromGitHub {
        owner = "nairdahh";
        repo = "Anchorr";
        tag = version;
        hash = "sha256-M95ZBxdlUSeHJb/jwfwKKxBz9FZ11i8j0SpQ9gY9m2U=";
      };
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
