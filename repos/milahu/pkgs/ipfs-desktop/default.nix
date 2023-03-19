# nix-build -E 'with import <nixpkgs> { }; callPackage ./default.nix { }'
/*
FIXME
build fails silently
  build:webui:download
    pnpx ipfs-or-gateway -c bafybeiflkjt66aetfgcrgvv75izymd5kc47g6luepqmfq6zsf5w6ueth6y -p assets/webui/ -t 360000 --verbose --clean
    -> write files to assets/webui/
    https://github.com/ipfs-shipyard/ipfs-or-gateway
*/


/* FIXME 3 derivations with same name -> use diff names
these derivations will be built:
  /nix/store/nkynfgl38pjx71w4yfpwjnwiwllm26y8-ipfs-desktop-0.16.2.drv
  /nix/store/q3bqahb4wraj8zd06vy2inhfrhgs1h2y-ipfs-desktop-0.16.2.drv
  /nix/store/f8qfi9wjw76d958lwhz9zx6rmvb28byd-ipfs-desktop-0.16.2.drv
*/

/* FIXME

renderer_init.js:93 Unable to load preload script: /nix/store/r78la8wl3h06gmmx6bsl6ngdpc5lyf2z-ipfs-desktop-0.16.2/src/webui/preload.js

renderer_init.js:93 DOMException: Failed to read the 'localStorage' property from 'Window': Access is denied for this document.
    at Object.<anonymous> (/nix/store/r78la8wl3h06gmmx6bsl6ngdpc5lyf2z-ipfs-desktop-0.16.2/src/webui/preload.js:68:8)
    at Object.<anonymous> (/nix/store/r78la8wl3h06gmmx6bsl6ngdpc5lyf2z-ipfs-desktop-0.16.2/src/webui/preload.js:70:3)
    at Module._compile (internal/modules/cjs/loader.js:1078:30)
    at Object.Module._extensions..js (internal/modules/cjs/loader.js:1108:10)
    at Module.load (internal/modules/cjs/loader.js:935:32)
    at Module._load (internal/modules/cjs/loader.js:776:14)
    at Function.f._load (electron/js2c/asar_bundle.js:5:12913)
    at Function.o._load (electron/js2c/renderer_init.js:33:379)
    at Object.<anonymous> (electron/js2c/renderer_init.js:93:3262)
    at Object../lib/renderer/init.ts (electron/js2c/renderer_init.js:93:3531)

VM230 renderer_init.js:165 Electron renderer_init.js script failed to run
(anonymous) @ VM230 renderer_init.js:165
compileForInternalLoader @ VM165 loaders.js:283
compileForPublicLoader @ VM165 loaders.js:225
loadNativeModule @ VM205 helpers.js:35
Module._load @ VM198 loader.js:747
f._load @ VM225 asar_bundle.js:5
executeUserEntryPoint @ VM224 run_main.js:72
(anonymous) @ VM193 run_main_module.js:17

VM230 renderer_init.js:165 Error: An object could not be cloned.
    at EventEmitter.i.send (VM230 renderer_init.js:105)
    at Object.<anonymous> (VM230 renderer_init.js:93)
    at Object../lib/renderer/init.ts (VM230 renderer_init.js:93)
    at __webpack_require__ (VM230 renderer_init.js:1)
    at VM230 renderer_init.js:1
    at ___electron_webpack_init__ (VM230 renderer_init.js:1)
    at VM230 renderer_init.js:165
    at NativeModule.compileForInternalLoader (VM165 loaders.js:283)
    at NativeModule.compileForPublicLoader (VM165 loaders.js:225)
    at loadNativeModule (VM205 helpers.js:35)
(anonymous) @ VM230 renderer_init.js:165
compileForInternalLoader @ VM165 loaders.js:283
compileForPublicLoader @ VM165 loaders.js:225
loadNativeModule @ VM205 helpers.js:35
Module._load @ VM198 loader.js:747
f._load @ VM225 asar_bundle.js:5
executeUserEntryPoint @ VM224 run_main.js:72
(anonymous) @ VM193 run_main_module.js:17

*/



# FIXME nix: debug syntax errors in bash scripts
# /nix/store/r4bl79l2bdjawmr2rhhqvci56qh0fkvv-stdenv-linux/setup: eval: line 1320: unexpected EOF while looking for matching `''
# -> show context in source around line 1320

/* low prio: use native dependencies
shrinking RPATHs of ELF executables and libraries in /nix/store/pr7d2gfl941s1id05l5rdvgcfnv91bhg-ipfs-desktop-0.16.2
shrinking /nix/store/pr7d2gfl941s1id05l5rdvgcfnv91bhg-ipfs-desktop-0.16.2/node_modules/7zip-bin/linux/ia32/7za
shrinking /nix/store/pr7d2gfl941s1id05l5rdvgcfnv91bhg-ipfs-desktop-0.16.2/node_modules/7zip-bin/linux/x64/7za
shrinking /nix/store/pr7d2gfl941s1id05l5rdvgcfnv91bhg-ipfs-desktop-0.16.2/node_modules/7zip-bin/linux/arm64/7za
shrinking /nix/store/pr7d2gfl941s1id05l5rdvgcfnv91bhg-ipfs-desktop-0.16.2/node_modules/7zip-bin/linux/arm/7za
shrinking /nix/store/pr7d2gfl941s1id05l5rdvgcfnv91bhg-ipfs-desktop-0.16.2/node_modules/app-builder-bin/linux/ia32/app-builder
shrinking /nix/store/pr7d2gfl941s1id05l5rdvgcfnv91bhg-ipfs-desktop-0.16.2/node_modules/app-builder-bin/linux/x64/app-builder
shrinking /nix/store/pr7d2gfl941s1id05l5rdvgcfnv91bhg-ipfs-desktop-0.16.2/node_modules/app-builder-bin/linux/arm64/app-builder
shrinking /nix/store/pr7d2gfl941s1id05l5rdvgcfnv91bhg-ipfs-desktop-0.16.2/node_modules/app-builder-bin/linux/arm/app-builder
*/

/* based on
https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/networking/instant-messengers/element/element-desktop.nix
*/

{ lib
, stdenv
, fetchFromGitHub
#, fetchgit # https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/fetchgit/default.nix
, callPackage
, electron
, python3
, chromedriver
, writeText
, jq
, moreutils # sponge
, ipfs
, useWayland ? false
, makeWrapper
, curl
, makeDesktopItem
#, fetchipfs # https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/fetchipfs/default.nix
#, electron-chromedriver
#, python
/*
, which
, curl
, wget
*/
}:

let
  npmlock2nix = callPackage /home/user/src/brave/lib/npmlock2nix/default.nix {}; # local version
  /*
  npmlock2nix = callPackage (fetchFromGitHub rec {
    name = "npmlock2nix-source";
    repo = "npmlock2nix";
    owner = "milahu";
    rev = "47e300362becca195b45247ce470d7f8cb42dc48";
    sha256 = "0czqah9876jg0wbi04n5c7asra27w806mysx3x2nxi996xzm0ql3";
  } + "/default.nix") {};
  */

  version = "0.16.2";

  #src = /home/user/src/ipfs/ipfs-desktop;
  # TODO rm -rf /home/user/src/ipfs/ipfs-desktop/assets/webui
  src = fetchFromGitHub rec {
    name = "${repo}-source-${rev}";
    repo = "ipfs-desktop";

    #owner = "ipfs";
    #rev = "v${version}";
    #sha256 = "15kyk79miakpa64gll2xqp7bblf3spgmrw3kcjgqvknb8anz00hn";

    # https://github.com/ipfs/ipfs-desktop/pull/1900 fix: analytics storage_path
    owner = "milahu";
    rev = "ee5fa8118e2e6b32d2f3f81d064b2981c42f30a7";
    sha256 = "1f9fdgjakailsq3krs8r0ik84y9m3b4qj70z0gqqkjvc06qhg4k3"; # todo
  };

  chromedriver-src = fetchFromGitHub rec {
    name = "${repo}-source-${rev}";
    repo = "chromedriver";
    owner = "electron";
    rev = "3ef0ef274ac61e2b03238aed213e132448de760e";
    sha256 = "12i0g56afcbklipf42gblr27irajvzl582iy4rv712b0nns2hzn0";
  };

  chromedriver-zip = builtins.fetchurl {
    url = "https://github.com/electron/electron/releases/download/v14.0.0/chromedriver-v14.0.0-linux-x64.zip";
    sha256 = "1lp8x2ca31k188f69cppj0wdbwq8xk2nq30dldadpw3djjrinj1p";
  };


  # https://github.com/NixOS/nixpkgs/pull/136688
  fetchipfs = import ./fetchipfs {
    inherit curl stdenv;
  };

  ipfs-desktop-assets-webui = fetchipfs rec {
    # ipfs-desktop/package.json script build:webui:download
    ipfs = "bafybeiflkjt66aetfgcrgvv75izymd5kc47g6luepqmfq6zsf5w6ueth6y";
    sha256 = "0p8w97j6rxnackm14p9npbra5a82irdb50i80qjc0pfpzjk781dm";
  };

  npm-dist = builtins.trace "call npmlock2nix.build" npmlock2nix.build {

    inherit src;
    #src = chromedriver-src;
    #src = /home/user/src/nixos/milahu--nixos-packages/nur-packages/pkgs/ipfs-desktop/play/get-electron-chromedriver;

    node_modules_attrs = {
      #name = "ipfs-desktop-npm-dist"; # TODO
      buildInputs = [
        python3 # for node-gyp
        jq
        moreutils # sponge
        #libwebp # cwebp-bin
      ];
      preInstallLinks = {
        #"cwebp-bin"."vendor/cwebp" = "${libwebp}/bin/cwebp";
        # TODO add electron-chromedriver to nixpkgs nodePackages
        # https://github.com/electron/chromedriver/blob/main/download-chromedriver.js
        # https://github.com/electron/chromedriver/issues/78
        #"electron-chromedriver"."node_modules/electron-chromedriver/bin/chromedriver" = "${chromedriver}/bin/chromedriver";
        #"electron-chromedriver"."download-chromedriver.js" = writeText "download-chromedriver.js" ''
        #  console.log("asdfasdfasdfasdfasdfasdfasdf");
        #'';


        #"countly-sdk-nodejs"."./data/" = writeText "__cly_id.json" "{}"; # FIXME get data
        # FIXME ln: failed to create symbolic link './data/': No such file or directory
        #"countly-sdk-nodejs"."data/__cly_id.json" = writeText "__cly_id.json" "{}"; # FIXME get data

        # https://github.com/ipfs/npm-go-ipfs/blob/master/src/index.js#L8
        "go-ipfs"."go-ipfs/ipfs" = "${ipfs}/bin/ipfs";

      };
      
      preBuild = ''
        echo "################ custom preBuild start ################"

        # package.json is a read-only symlink, copy for write access
        mv package.json package.json.bak
        cp package.json.bak package.json

        if false
        then
          dependency_version_electron_chromedriver=$(cat package.json | jq -r '."dependencies"."electron-chromedriver"')
          echo "remove dependency: electron-chromedriver $dependency_version_electron_chromedriver"
          cat package.json | jq -r 'del(."dependencies"."electron-chromedriver")' | sponge package.json

          dependency_version_electron=$(cat package.json | jq -r '."dependencies"."electron"')
          echo "remove dependency: electron $dependency_version_electron"
          cat package.json | jq -r 'del(."dependencies"."electron")' | sponge package.json
        fi

        #cat package.json | jq

        mkdir /tmp/home
        export HOME=/tmp/home

        # populate cache
        chromedriver_dir=$HOME/.cache/electron/385ab57c1ff3ee205462577b7d7844ec5661943eda4db02aad16cb90456aab69
        mkdir -p $chromedriver_dir
        ############## TEST cp -v ${chromedriver-zip} $chromedriver_dir/

        echo "################ custom preBuild end ################"
      '';

      postBuild = ''
        echo "################ custom postBuild start ################"

        if false
        then
          echo "add dependency: electron-chromedriver $dependency_version_electron_chromedriver"
          cat package.json | jq -r '."dependencies"."electron-chromedriver" = "'"$dependency_version_electron_chromedriver"'"' | sponge package.json

          echo "add dependency: electron $dependency_version_electron"
          cat package.json | jq -r '."dependencies"."electron" = "'"$dependency_version_electron"'"' | sponge package.json
        fi

        echo "ignore script: clean"
        cat package.json | jq -r '."scripts"."clean" = "echo \"ignore script: clean\""' | sponge package.json
        echo "verify: new clean script: $(cat package.json | jq -r '."scripts"."clean"')"

        #cat package.json | jq
        echo "################ custom postBuild end ################"
      '';

      # FIXME is this ignored?
      buildCommands = [
        "buildCommands 170"
        "exit 1"
        "echo buildCommands via build node_modules_attrs"
        "echo buildCommands ls node_modules"
        "ls node_modules"
        "npm run build"
      ];

    };

    buildInputs = [
      #electron
      jq
      moreutils # sponge
      #electron-chromedriver
      #ipfs-desktop-assets-webui # todo?
    ];

    buildCommands = [ # called after build TODO what is this good for?

      ''[ -d assets/webui ] && { echo "error: source is not clean"; exit 1; }''
      ''cp -r ${ipfs-desktop-assets-webui} assets/webui''
      ''chmod -R +w assets/webui'' # allow to delete files later in build

      # add icon to assets
      # TODO use icon.png
      ''cat assets/webui/asset-manifest.json | jq -r '."files"."favicon.ico" = "./favicon.ico"' | sponge assets/webui/asset-manifest.json''
      # TODO add locales? assets/webui/locales/de/app.json ...

      ''echo "ignore script: build:webui:download"''
      ''cat package.json | grep '"build:webui:download"' ''
      ''cat package.json | jq -r '."scripts"."build:webui:download" = "echo \"ignore script: build:webui:download\""' | sponge package.json''
      ''echo "verify: new build:webui:download script: $(cat package.json | jq -r '."scripts"."build:webui:download"')"''

      # keep sourcemaps
      ''echo "ignore script: build:webui:minimize"''
      ''cat package.json | grep '"build:webui:minimize"' ''
      ''cat package.json | jq -r '."scripts"."build:webui:minimize" = "echo \"ignore script: build:webui:minimize\""' | sponge package.json''
      ''echo "verify: new build:webui:minimize script: $(cat package.json | jq -r '."scripts"."build:webui:minimize"')"''

      ''echo "ignore script: clean"''
      ''cat package.json | grep '"clean"' ''
      ''cat package.json | jq -r '."scripts"."clean" = "echo \"ignore script: clean\""' | sponge package.json''
      ''echo "verify: new clean script: $(cat package.json | jq -r '."scripts"."clean"')"''

      ''ln -s assets/webui/ipfs-logo-512-ice.png icon.png''

      "mkdir /tmp/home"
      "export HOME=/tmp/home"

      "npm run build"
      # FIXME "npm update check failed"
    ];

    installPhase = ''
      cp -r . $out
    '';
  };




  # The desktop item properties should be kept in sync with data from upstream:
  # https://github.com/vector-im/element-desktop/blob/develop/package.json
  desktopItem = makeDesktopItem {
    name = "ipfs-desktop";
    #exec = "${executableName} %u";
    exec = "${executableName}";
    icon = "ipfs";
    desktopName = "IPFS Desktop";
    genericName = "Distributed Web";
    # IPFS Powers the Distributed Web
    # A peer-to-peer hypermedia protocol
    # designed to preserve and grow humanity's knowledge
    # by making the web upgradeable, resilient, and more open.
    #comment = meta.description;
    categories = [ "Network" "FileTransfer" "P2P" ];
    /*
    error: makeDesktopItem called with unexpected argument 'extraEntries'
    extraEntries = ''
      StartupWMClass=ipfs
      MimeType=x-scheme-handler/ipfs;
    '';
    */
  };

  # https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/networking/instant-messengers/element/element-desktop.nix
  electron_exec = if stdenv.isDarwin then "${electron}/Applications/Electron.app/Contents/MacOS/Electron" else "${electron}/bin/electron";
  executableName = "ipfs-desktop";
in

stdenv.mkDerivation rec {
  pname = "ipfs-desktop";
  inherit version;
  src = ./.; # not used
  buildInputs = [
    electron
    ipfs
    npm-dist
  ];
  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    # resources
    mkdir -p $out/share/ipfs-desktop
    ln -s ${npm-dist} $out/share/ipfs-desktop/electron

    # icons
    mkdir -p $out/share/icons/hicolor/512x512/apps
    cp ${ipfs-desktop-assets-webui}/ipfs-logo-512-ice.png $out/share/icons/hicolor/512x512/apps/ipfs.png

    # desktop item
    mkdir -p "$out/share"
    ln -s "${desktopItem}/share/applications" "$out/share/applications"

    # executable wrapper
    makeWrapper '${electron_exec}' "$out/bin/${executableName}" \
      --add-flags "$out/share/ipfs-desktop/electron --trace-warnings${lib.optionalString useWayland " --enable-features=UseOzonePlatform --ozone-platform=wayland"}"
  '';




  /*
  FIXME
  Error: EROFS: read-only file system, mkdir '/nix/store/pr7d2gfl941s1id05l5rdvgcfnv91bhg-ipfs-desktop-0.16.2/node_modules/countly-sdk-nodejs/data'
    at Object.mkdirSync (fs.js:987:3)
    at Object.Countly.init (/nix/store/pr7d2gfl941s1id05l5rdvgcfnv91bhg-ipfs-desktop-0.16.2/node_modules/countly-sdk-nodejs/lib/countly.js:157:24)
    at module.exports (/nix/store/aq30gw863idbjzw44qkkq3mpzgzsb6rq-ipfs-desktop-0.16.2/src/analytics.js:6:11)
    at run (/nix/store/aq30gw863idbjzw44qkkq3mpzgzsb6rq-ipfs-desktop-0.16.2/src/index.js:68:11)
Error: ENOENT: no such file or directory, open '/nix/store/pr7d2gfl941s1id05l5rdvgcfnv91bhg-ipfs-desktop-0.16.2/node_modules/countly-sdk-nodejs/data/__cly_id.json'
    at Object.openSync (fs.js:476:3)
    at Object.func [as openSync] (electron/js2c/asar_bundle.js:5:1846)
    at Object.writeFileSync (fs.js:1467:35)
    at storeSet (/nix/store/pr7d2gfl941s1id05l5rdvgcfnv91bhg-ipfs-desktop-0.16.2/node_modules/countly-sdk-nodejs/lib/countly.js:1337:16)
    at Object.Countly.init (/nix/store/pr7d2gfl941s1id05l5rdvgcfnv91bhg-ipfs-desktop-0.16.2/node_modules/countly-sdk-nodejs/lib/countly.js:171:21)
    at module.exports (/nix/store/aq30gw863idbjzw44qkkq3mpzgzsb6rq-ipfs-desktop-0.16.2/src/analytics.js:6:11)
    at run (/nix/store/aq30gw863idbjzw44qkkq3mpzgzsb6rq-ipfs-desktop-0.16.2/src/index.js:68:11)
(node:2394069) electron: Failed to load URL: webui://-/?deviceId=f3740d4b-2579-47bc-9c09-571420698d46&lng=#/blank with error: ERR_FILE_NOT_FOUND
(Use `electron --trace-warnings ...` to show where the warning was created)
2021-09-04T05:35:48.346Z info: [web ui] window ready
2021-09-04T05:35:48.348Z info: [web ui] navigate to /
2021-09-04T05:35:48.412Z info: [tray] starting
2021-09-04T05:35:48.937Z info: [tray] started
2021-09-04T05:35:48.996Z info: [ipfsd] start daemon STARTED
2021-09-04T05:35:49.306Z error: [ipfsd] start daemon Error: go-ipfs binary not found, it may not be installed or an error may have occured during installation
    at Object.module.exports.path (/nix/store/pr7d2gfl941s1id05l5rdvgcfnv91bhg-ipfs-desktop-0.16.2/node_modules/go-ipfs/src/index.js:18:9)
    at getIpfsBinPath (/nix/store/aq30gw863idbjzw44qkkq3mpzgzsb6rq-ipfs-desktop-0.16.2/src/daemon/daemon.js:26:8)
    at spawn (/nix/store/aq30gw863idbjzw44qkkq3mpzgzsb6rq-ipfs-desktop-0.16.2/src/daemon/daemon.js:39:19)
    at module.exports (/nix/store/aq30gw863idbjzw44qkkq3mpzgzsb6rq-ipfs-desktop-0.16.2/src/daemon/daemon.js:73:37)
    at startIpfs (/nix/store/aq30gw863idbjzw44qkkq3mpzgzsb6rq-ipfs-desktop-0.16.2/src/daemon/index.js:54:21)
    at module.exports (/nix/store/aq30gw863idbjzw44qkkq3mpzgzsb6rq-ipfs-desktop-0.16.2/src/daemon/index.js:116:9)
    at run (/nix/store/aq30gw863idbjzw44qkkq3mpzgzsb6rq-ipfs-desktop-0.16.2/src/index.js:74:11)
    at processTicksAndRejections (internal/process/task_queues.js:93:5)
2021-09-04T05:35:49.455Z info: [automatic gc] enabled
2021-09-04T05:35:49.467Z info: [pubsub] disabled
2021-09-04T05:35:49.476Z info: [ipns over pubsub] disabled
2021-09-04T05:35:49.546Z info: [npm on ipfs] 1st time running and package is installed
2021-09-04T05:35:49.626Z info: [launch on startup] disabled
(node:2394069) electron: Failed to load URL: webui://-/?deviceId=f3740d4b-2579-47bc-9c09-571420698d46&lng=#/ with error: ERR_FILE_NOT_FOUND
*/
}
