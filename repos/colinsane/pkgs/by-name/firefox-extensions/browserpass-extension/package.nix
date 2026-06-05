{
  fetchFromGitHub,
  fetchYarnDeps,
  gitUpdater,
  mkYarnModules,
  nodejs,
  stdenvNoCC,
  wrapFirefoxAddonsHook,
  yarnConfigHook,
  zip,
}:

let
  pname = "browserpass-extension";
  version = "3.12.0";
  src = fetchFromGitHub {
    owner = "browserpass";
    repo = "browserpass-extension";
    rev = version;
    hash = "sha256-HDQCI/ugtM/AkEruLuRl8d8O+M/NIGX8lqMlZohJbd4=";
  };
  # src = fetchFromGitea {
  #   domain = "git.uninsane.org";
  #   owner = "colin";
  #   repo = "browserpass-extension";
  #   # hack in sops support
  #   rev = "e3bf558ff63d002d3c15f2ce966071f04fada306";
  #   sha256 = "sha256-dSRZ2ToEOPhzHNvlG8qdewa7689gT8cNB7nXkN3/Avo=";
  # };
  # browserpass-extension-yarn-modules = mkYarnModules {
  #   inherit version;
  #   pname = "${pname}-modules";
  #   packageJSON = "${src}/src/package.json";
  #   # XXX(2025-12-14): this triggers IFD, but NUR & system configs *seem* to be OK with that??
  #   yarnLock = "${src}/src/yarn.lock";
  #   # offlineCache = fetchYarnDeps {
  #   #   yarnLock = "${src}/src/yarn.lock";
  #   #   # yarnLock = ./yarn.lock;
  #   #   hash = "sha256-8cKFbrY3EcQBCnwJHFgPCL7HZnM6w4edwkkibMLVyRQ=";
  #   # };
  # };
in stdenvNoCC.mkDerivation {
  inherit pname src version;

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = "${src}/src/yarn.lock";
    hash = "sha256-vhoiPPWfZH7QD54wMH9fXacBcrIcfy7BHIPNOYm+tWM=";
  };

  nativeBuildInputs = [
    nodejs
    wrapFirefoxAddonsHook
    yarnConfigHook
    zip
  ];

  postPatch = ''
    # dependencies are built separately: skip the yarn install
    # prettier, lessc, browserify are made available here via the modules,
    # which are for the host (even the devDependencies are compiled for the host).
    # but we can just run those via the build node.
    #
    # alternative would be to patchShebangs in the node_modules dir.
    substituteInPlace src/Makefile \
      --replace-fail "yarn install" "true"
    # yarnConfigHook requires `yarn.lock` to be at `$src/yarn.lock`,
    # and then it installs node_modules to `$src/node_modules` instead of `$src/src/node_modules`
    ln -s src/yarn.lock yarn.lock
    ln -s src/package.json package.json
    ln -s ../node_modules src/node_modules
  '';

  installPhase = ''
    pushd firefox
    mkdir $out
    zip -r $out/$extid.xpi ./*
    popd
  '';

  extid = "browserpass@maximbaz.com";
  keepFirefoxPermissions = [
    "activeTab"
    "alarms"
    "tabs"
    "clipboardRead"
    "clipboardWrite"
    "nativeMessaging"
    # "notifications"  #< remove `notifications` perm, else it spams info for where to file bug reports, etc, on first launch
    "scripting"
    "storage"
    "webRequest"
    "webRequestAuthProvider"
  ];

  passthru = {
    updateScript = gitUpdater { };
  };
}
