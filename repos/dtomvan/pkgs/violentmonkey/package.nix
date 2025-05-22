{
  lib,
  callPackage,
  buildFirefoxXpiAddon ? callPackage ../../lib/buildFirefoxXpiAddon.nix { },
  stdenv,
  fetchYarnDeps,
  fetchFromGitHub,
  yarnConfigHook,
  yarnBuildHook,
  nodejs,
  zip,
  pkg-config,
  vips,
  python3,
  nix-update-script,
}:
let
  xpifile = stdenv.mkDerivation rec {
    pname = "violentmonkey";
    version = "2.31.0";

    src = fetchFromGitHub {
      owner = "violentmonkey";
      repo = "violentmonkey";
      rev = "v${version}";
      hash = "sha256-e3266zVqVmsafq0ToL+ZMVMripOoz5AUVSDjmWSdeYM=";
    };

    yarnOfflineCache = fetchYarnDeps {
      yarnLock = src + "/yarn.lock";
      hash = "sha256-O3373btwBNl7ASzhAf7pxSBSv8LwTuWe6HIkInBhLY4=";
    };

    buildInputs = [ vips ];

    nativeBuildInputs = [
      pkg-config
      yarnConfigHook
      yarnBuildHook
      # Needed for executing package.json scripts
      nodejs
      # Needed to build sharp from source
      (python3.withPackages (p: with p; [ distutils ]))
    ];

    # we could also inject a prebuilt version into
    # node_modules/sharp/Build/Release/... but that would require mapping
    # `system` to whatever naming scheme sharp got going on
    #
    # then we'd need to keep the versions in sync with the one in the
    # violentmonkey repo, no thank you
    preBuild = ''
      # from javascript.section.md
      mkdir -p $HOME/.node-gyp/${nodejs.version}
      echo 9 > $HOME/.node-gyp/${nodejs.version}/installVersion
      ln -sfv ${nodejs}/include $HOME/.node-gyp/${nodejs.version}
      export npm_config_nodedir=${nodejs}

      pushd node_modules/sharp
      npm run install --build-from-source
      popd
    '';

    installPhase = ''
      runHook preInstall

      pushd dist
      ${lib.getExe zip} -r $out *
      popd

      runHook postInstall
    '';

    passthru.updateScript = nix-update-script { };
  };
in
buildFirefoxXpiAddon {
  inherit (xpifile) pname version;
  src = xpifile;

  addonId = "{aecec67f-0d10-4fa7-b7c7-609a2db280cf}";

  meta = {
    description = "Violentmonkey provides userscripts support for browsers. It works on browsers with WebExtensions support";
    homepage = "https://github.com/violentmonkey/violentmonkey";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dtomvan ];
    platforms = lib.platforms.all;
    mozPermissions = [
      "tabs"
      "<all_urls>"
      "webRequest"
      "webRequestBlocking"
      "notifications"
      "storage"
      "unlimitedStorage"
      "clipboardWrite"
      "contextMenus"
      "cookies"
    ];
  };
}
