{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  importNpmLock,
}:

buildNpmPackage (finalAttrs: 
  let
    browser = "chrome";
  in rec {
  pname = "surfingkeys";
  # Not traditionally versioned
  version = "2024-07-15";

  src = fetchFromGitHub {
    owner = "brookhong";
    repo = "surfingkeys";
    rev = "965301c079852f9d310145d823628d107e940588";
    hash = "sha256-nwkgyEuUIFEmohEHxKONOAP98c45XHuBWx3+8km47Eo=";
  };

  # `build` target also builds docs. We just want the extension.
  npmBuildScript = "build:prod";

  npmDeps = importNpmLock {
    npmRoot = src;
    # No package-lock.json upstream, add our own.
    packageLock =  lib.importJSON ./package-lock.json;
  };
  npmConfigHook = importNpmLock.npmConfigHook;

  # We don't need puppeteer unless we are running tests.
  # However, it's included in dependencies.
  # Just skip downloading the browser instead of
  # patching puppeteer out.
  env.PUPPETEER_SKIP_DOWNLOAD = true;

  # Target browser: chrome|firefox
  # surfingkeys-specific
  env.browser = browser;

  # Nothing fancy, just dump the extension files
  # into the output directory. Maybe one day
  # this will be $out/share/...
  installPhase = ''
    mkdir -p "$out"
    cp -r "dist/production/${browser}/." "$out"
  '';

  meta = {
    description = "Map your keys for web surfing, expand your browser with javascript and keyboard.";
    homepage = "https://github.com/brookhong/Surfingkeys";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [  ];
  };
})
