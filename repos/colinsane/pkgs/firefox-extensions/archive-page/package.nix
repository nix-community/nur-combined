{
  fetchFromGitHub,
  lib,
  stdenvNoCC,
  gitUpdater,
  wrapFirefoxAddonsHook,
  zip,
}:

stdenvNoCC.mkDerivation rec {
  pname = "archive-page";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "JNavas2";
    repo = "Archive-Page";
    rev = "v${version}";
    hash = "sha256-Cwhs2LbfCHk39E+UbpR2qZZ45fbRhVzfF+RgXiZlMXM=";
  };

  nativeBuildInputs = [
    wrapFirefoxAddonsHook
    zip
  ];

  postPatch = ''
    # don't open options on first install/update
    substituteInPlace Firefox/background.js --replace-fail \
      'browserAPI.runtime.openOptionsPage()' \
      '// browserAPI.runtime.openOptionsPage()'
  '';

  buildPhase = ''
    runHook preBuild
    ( cd Firefox; zip -r ../extension.zip images/ *.js *.json *.html )
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir $out
    install extension.zip $out/$extid.xpi
    runHook postInstall
  '';

  extid = "{5b22cb75-8e43-4f2a-bb9b-1da0655ae564}";

  passthru = {
    updateScript = gitUpdater {
      rev-prefix = "v";
    };
  };

  meta = {
    homepage = "https://github.com/JNavas2/Archive-Page/";
    description = "Official archive.is extension that provides a toolbar button to quickly archive (or view) any page";
    maintainer = with lib.maintainers; [ colinsane ];
  };
}
