{
  fetchFromGitHub,
  lib,
  stdenvNoCC,
  gitUpdater,
  wrapFirefoxAddonsHook,
  zip,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "archive-page";
  version = "1.6.3";

  src = fetchFromGitHub {
    owner = "JNavas2";
    repo = "Archive-Page";
    rev = "v${finalAttrs.version}";
    hash = "sha256-F74YWHkP9wdMo2f81ghkQDbjlXVOP+mxA4bmh3vnd10=";
  };

  nativeBuildInputs = [
    wrapFirefoxAddonsHook
    zip
  ];

  postPatch = ''
    # don't open options on first install/update
    substituteInPlace Firefox/background.js --replace-fail \
      'browserAPI.tabs.create({ url: browserAPI.runtime.getURL("welcome.html") });' \
      '// browserAPI.tabs.create({ url: browserAPI.runtime.getURL("welcome.html") });'
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
  keepFirefoxPermissions = [
    "activeTab"
    "contextMenus"
    # "notifications"  #< remove `notifications` perm else it (appears to) spams you when "updated"
    "storage"
  ];

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
})
