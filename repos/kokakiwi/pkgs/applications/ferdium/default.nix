{ lib, stdenv

, fetchFromGitHub

, makeDesktopItem
, makeWrapper
, wrapGAppsHook

, electron
, gitMinimal
, jq
, nodejs
, pnpm
}:
let
  fixupPackageJson = {
    pnpmPatch = builtins.toJSON {
      pnpm.supportedArchitectures = {
        os = [ "linux" ];
        cpu = [ "x64" "arm64" ];
      };
      engines = {
        node = nodejs.version;
        pnpm = pnpm.version;
        electron = electron.version;
      };
    };

    patch = ''
      mv package.json package.json.orig
      ${jq}/bin/jq --raw-output ". * $pnpmPatch" package.json.orig > package.json
    '';
  };
in stdenv.mkDerivation (finalAttrs: {
  pname = "ferdium";
  version = "7.1.0";

  src = fetchFromGitHub {
    owner = "ferdium";
    repo = "ferdium-app";
    rev = "v${finalAttrs.version}";
    hash = "sha256-uYkvDme7BmN5Z0rZJmOxtq4+C7pLiZNI++PsmIvVFr0=";
  };

  inherit (fixupPackageJson) pnpmPatch;

  pnpmDeps = pnpm.fetchDeps {
    inherit (finalAttrs) pname version src;

    inherit (fixupPackageJson) pnpmPatch;
    postPatch = fixupPackageJson.patch;

    hash = "sha256-j2E41BenWfVygJvZhh+PvIwT/w9UpwNcZ4xWR8lLs+Q=";
  };

  recipes = stdenv.mkDerivation (recipesFinalAttrs: {
    pname = "${finalAttrs.pname}-recipes";
    inherit (finalAttrs) version;

    src = fetchFromGitHub {
      owner = "ferdium";
      repo = "ferdium-recipes";
      rev = "c392b20eca0dc315784500bf39d28062066cb2ff";
      hash = "sha256-Yyj5FGiFdx6B+iceu/BGYLYeLLVzI2NuULaBVODxxts=";
    };

    pnpmDeps = pnpm.fetchDeps {
      inherit (recipesFinalAttrs) pname version src;

      inherit (fixupPackageJson) pnpmPatch;
      postPatch = fixupPackageJson.patch;

      hash = "sha256-pk5z5t75TuRQ7GWA/SvgTM5C0RvHDxJ7w/A6Js76vJ8=";
    };

    inherit (fixupPackageJson) pnpmPatch;
    postPatch = fixupPackageJson.patch;

    nativeBuildInputs = [
      nodejs
      pnpm.configHook
      gitMinimal
    ];

    postBuild = ''
      pnpm run package
    '';

    installPhase = ''
      runHook preInstall

      mkdir $out
      cp -T all.json $out/all.json
      cp -Tr archives $out/archives

      runHook postInstall
    '';
  });

  nativeBuildInputs = [
    nodejs
    pnpm.configHook
    makeWrapper
    wrapGAppsHook
  ];

  dontPatchShebangs = true;
  dontPatchELF = true;

  postPatch = ''
    cat > src/electron/ipc-api/dnd.ts <<"EOF"
    import { ipcMain } from 'electron';
    export default async () => {
      ipcMain.handle('get-dnd', async () => {
        return false;
      });
    };
    EOF

    ${fixupPackageJson.patch}
  '';

  postBuild = ''
    pnpm manage-translations
    node esbuild.mjs

    cp -Tr node_modules build/node_modules
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share

    cp -Tr build $out/share/ferdium
    cp -Tr node_modules $out/share/ferdium/node_modules

    makeWrapper ${electron}/bin/electron $out/bin/ferdium \
      --set ELECTRON_IS_DEV 0 \
      --add-flags $out/share/ferdium

    ln -s "${finalAttrs.desktopItem}/share/applications" $out/share/applications

    for _size in 16 24 32 48 64 96 128 256 512 1024; do
      install -Dm0644 "build-helpers/images/icons/''${_size}x''${_size}.png" \
        "$out/share/icons/hicolor/''${_size}x''${_size}/apps/ferdium.png"
    done

    runHook postInstall
  '';

  desktopItem = makeDesktopItem {
    name = "ferdium";
    exec = "ferdium %U";
    icon = "ferdium";
    desktopName = "Ferdium";
    startupWMClass = "Ferdium";
    terminal = false;
    comment = finalAttrs.meta.description;
    categories = [ "Network" "InstantMessaging" ];
  };

  passthru = {
    inherit (finalAttrs) recipes;
  };

  meta = with lib; {
    description = "All your services in one place built by the community";
    homepage = "https://ferdium.org/";
    changelog = "https://github.com/ferdium/ferdium-app/releases/tag/v${finalAttrs.version}";
    license = licenses.asl20;
    platforms = electron.meta.platforms;
    mainProgram = "ferdium";
  };
})
