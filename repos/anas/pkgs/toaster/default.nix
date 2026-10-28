{ lib
, buildNpmPackage
, fetchFromGitHub
, electron_44
, makeWrapper
}:

let
  pname = "toaster";
  version = "0.4.22";
in
buildNpmPackage rec {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "StopBanning";
    repo = "toaster";
    rev = "v${version}";
    hash = "sha256-vBPxHprRIHycIC/j40TE4xfIBh9BJE8vlNr9wI2Xr0k=";
  };

  patches = [
    ./0001-clean-remove-the-auto-update-functionality.patch
    ./0002-chore-npm-update-the-packages.patch
  ];

  npmDepsHash = "sha256-MLMwA7Q1LNNexMmTpcDpZmytCKPTOCJW5AXOGApV3C0=";

  # Electron is only needed for development (via `npm start`), not at runtime:
  # the app runs on the nixpkgs Electron below.
  npmInstallFlags = [ "--omit=dev" ];

  # The upstream build script only packages the app with Electron's packager,
  # which is not what we want here.
  dontNpmBuild = true;

  nativeBuildInputs = [ makeWrapper ];

  postInstall = ''
    # The GPU process' sandbox can't see the graphics drivers in
    # /run/opengl-driver on NixOS; without this Mesa fails to load them and
    # Electron eventually dies ("GPU process isn't usable. Goodbye.").
    makeWrapper ${electron_44}/bin/electron $out/bin/${pname} \
      --add-flags "$out/lib/node_modules/${pname}" \
      --add-flags "--disable-gpu-sandbox"

    install -Dm644 build/icon.png \
      $out/share/icons/hicolor/256x256/apps/${pname}.png
    install -Dm644 ${./toaster.desktop} \
      $out/share/applications/${pname}.desktop
  '';

  meta = {
    description = "Hears whatever is playing and writes it out as live Strudel code, with visuals";
    homepage = "https://github.com/StopBanning/toaster";
    changelog = "https://github.com/StopBanning/toaster/releases/tag/v${version}";
    license = lib.licenses.mit;
    mainProgram = pname;
    maintainers = with lib.maintainers; [ anas ];
    platforms = lib.platforms.linux;
  };
}
