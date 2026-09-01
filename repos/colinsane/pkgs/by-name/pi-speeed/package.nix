{
  fetchFromGitHub,
  lib,
  mkPiExtension,
  nix-update-script,
}:

mkPiExtension (finalAttrs: {
  pname = "pi-speeed";
  version = "0.4.0";

  outputs = [
    "out"
    "assets"
  ];

  src = fetchFromGitHub {
    owner = "somus";
    repo = "pi-speeed";
    tag = "v${finalAttrs.version}";
    hash = "sha256-vOLJCu+1sHksVyRUdtrMovtG1LKJhWeYZNluWVOa68g=";
  };

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-w35APZUoCsvLEnjY5hbQHKLpklp0+SCeebXM/c51xLo=";


  postPatch = ''
    # save/load data to XDG paths, not ~/.pi
    substituteInPlace src/config.ts --replace-fail \
      '.pi/agent/pi-speeed.json' \
      '.config/pi/pi-speeed.json'
    substituteInPlace src/stats.ts --replace-fail \
      '.pi/agent/pi-speeed-stats.json' \
      '.config/pi/pi-speeed-stats.json'

    substituteInPlace package.json \
      --replace-fail \
        '"check": "biome check ."' \
        '"check": "true"' \
      --replace-fail \
        '"typecheck": "tsc --noEmit"' \
        '"typecheck": "true"'
  '';

  dontNpmBuild = true;

  postInstall = ''
    mkdir -p $out/share/fonts/truetype
    mv $out/assets/runcat.ttf $out/share/fonts/truetype/runcat.ttf
    rmdir $out/assets
  '';

  postFixup = ''
    moveToOutput share/fonts/truetype/runcat.ttf $assets
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Pi extension that shows assistant output speed with a configurable RunCat speed badge";
    homepage = "https://github.com/somus/pi-speeed";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ colinsane ];
  };
})
