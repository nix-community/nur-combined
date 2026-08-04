{
  lib,
  buildNpmPackage,
  runCommand,
  python3,
  vsce,
  source,
  typenix,
}: let
  # Patch extension source: remove @vscode/vsce devDep (pulls in native keytar)
  extensionSrc =
    runCommand "typenix-extension-src" {
      src = "${source.src}/_extension";
      nativeBuildInputs = [python3];
    } ''
      cp -r $src $out
      chmod -R u+w $out
      python3 -c "
      import json
      with open('$out/package.json') as f:
          d = json.load(f)
      d['devDependencies'] = {k:v for k,v in d.get('devDependencies',{}).items() if 'vsce' not in k}
      with open('$out/package.json', 'w') as f:
          json.dump(d, f, indent=4)
          f.write('\n')
      "
    '';
in
  buildNpmPackage {
    pname = "typenix-vscode";
    version = "0-unstable-${source.date}";

    src = extensionSrc;

    npmDepsHash = "sha256-s4D+JxR6GCyL+LunCG5IZOncfOlahW1VfC/zKafhYQk=";

    nativeBuildInputs = [vsce];

    dontNpmBuild = true;

    buildPhase = ''
      runHook preBuild

      # Bundle extension JS
      npx esbuild src/extension.ts \
        --bundle \
        --external:vscode \
        --platform=node \
        --format=cjs \
        --outfile=dist/extension.bundle.js \
        --minify

      # Place binary and nixlibs
      mkdir -p lib/nixlibs
      cp ${typenix}/bin/typenix lib/typenix
      cp ${typenix}/share/nixlibs/*.d.ts lib/nixlibs/

      # Package VSIX
      vsce package --no-dependencies --allow-package-secrets slack -o typenix.vsix

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      install -Dm644 typenix.vsix $out/typenix.vsix

      runHook postInstall
    '';

    meta = {
      description = "TypeNix VS Code extension VSIX (build artifact)";
      homepage = "https://github.com/ryanrasti/typenix";
      license = lib.licenses.asl20;
      platforms = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
    };
  }
