{ lib
, stdenv
, fetchFromGitHub
, npmlock2nix
, buildGoModule
, wails
, strace
, makeDesktopItem
, copyDesktopItems
, imagemagick
}:

let

  version = "1.1.1-beta";

  src = fetchFromGitHub {
    owner = "rule110-io";
    repo = "surge";
    rev = "v${version}";
    hash = "sha256-cqo+Dqd9zL2LkoZyWjsTaY3lPegpFU9n1LwMKywrgjA=";
  };

  vendorHash = "sha256-ctk2ztjgN1u5vGWbW80NxbIBPYVjwW0bx/J5xNjtHVw=";

  src-frontend = src + "/frontend";

  surge-frontend = npmlock2nix.v2.build rec {
    pname = "surge-frontend";
    inherit version;
    src = src-frontend;

    # quickfix: Error: error:0308010C:digital envelope routines::unsupported
    # https://stackoverflow.com/questions/69692842/error-message-error0308010cdigital-envelope-routinesunsupported
    # TODO npm update
    NODE_OPTIONS = "--openssl-legacy-provider";

    # disable fancy output from "vue-cli-service build"
    #TERM = "dumb"; # no effect

    installPhase = ''
      cp -r . $out
    '';

    node_modules_attrs = {
      # fix: Error: No PostCSS Config found in: /nix/store/az9n1pqygagqqm9xzf126pfmxkvwng03-surge-1.1.1-beta/node_modules/vue-tour/dist
      # https://stackoverflow.com/questions/49709252/no-postcss-config-found
      postBuild = ''
        set -x
        d=node_modules/vue-tour/dist
        f=$d/postcss.config.js
        if [ -e $f ]; then
          stat $f
        else
          mkdir -p $d
          echo 'module.exports = {}' >$f
        fi
        set +x
        unset d f
      '';
    };
  };

in

buildGoModule rec {
  pname = "surge";
  inherit version src vendorHash;

  nativeBuildInputs = [
    wails
    #copyDesktopItems # not working
    imagemagick
  ];

  # wails offline build
  # fix: module lookup disabled by GOPROXY=off
  # -m: Skip mod tidy before compile
  # -nosyncgomod: Don't sync go.mod
  # -debug: Builds the application in debug mode
  # -v 2: verbose
  # https://discourse.nixos.org/t/go-module-lookup-disabled-by-goproxy-off/22640
  # https://github.com/NixOS/nixpkgs/issues/177632
  # ln -s ${surge-frontend} frontend
  # symlink fails: pattern frontend/dist: cannot embed directory frontend/dist: in non-directory frontend
  # chmod: fix: open /build/source/frontend/wailsjs/runtime/package.json: permission denied
  buildPhase = ''
    runHook preBuild

    rm -rf frontend
    cp -r ${surge-frontend} frontend
    chmod -R +w frontend

    export HOME=$TMP

    wails build -m -nosyncgomod -debug

    runHook postBuild
  '';

  desktopItem = makeDesktopItem {
    name = "Surge";
    exec = "surge";
    icon = "surge";
    comment = "P2P filesharing app";
    desktopName = "Surge";
    categories = [ "Network" "FileTransfer" ];
  };

  installPhase = ''
    mkdir -p $out/bin
    cp build/bin/surge $out/bin

    mkdir -p $out/share/applications
    cp $desktopItem/share/applications/* $out/share/applications

    mkdir -p $out/share/icons/hicolor/1024x1024/apps
    cp build/appicon.png $out/share/icons/hicolor/1024x1024/apps/${pname}.png
    for i in 16 24 48 64 96 128 256 512; do
      mkdir -p $out/share/icons/hicolor/''${i}x''${i}/apps
      convert -background none -resize ''${i}x''${i} build/appicon.png $out/share/icons/hicolor/''${i}x''${i}/apps/${pname}.png
    done
  '';

  meta = with lib; {
    description = "P2P filesharing app designed to utilize blockchain technologies to enable 100% anonymous file transfers";
    homepage = "https://github.com/rule110-io/surge";
    # license: why restrictive license with "All Rights Reserved"
    # https://github.com/rule110-io/surge/issues/123
    license = with licenses; [
      unfree
    ];
    maintainers = with maintainers; [ ];
  };
}
