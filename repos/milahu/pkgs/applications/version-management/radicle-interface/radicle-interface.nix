{ lib
, fetchFromGitHub
, npmlock2nix
, stdenv
, jq
}:

npmlock2nix.v2.build rec {
  pname = "radicle-interface";
  version = "1.0.0-unstable-2023-08-01";

  src = fetchFromGitHub {
    owner = "radicle-dev";
    repo = "radicle-interface";
    rev = "0d024759d3225e6adb5b3dbabf1b81bd7b7bfbfd";
    hash = "sha256-7W+SY5DgDNu/1sbG87Y3AvZRHFQDEhORFHBGPXnDLZ0=";
  };

  # https://github.com/radicle-dev/radicle-interface/blob/master/scripts/install-twemoji-assets
  #   version="$(node -e 'console.log(require("twemoji/package.json").version)')"
  #   curl -sSL "https://github.com/twitter/twemoji/archive/refs/tags/v${version}.tar.gz" \
  #     | tar -x -z -C public/twemoji/ --strip-components=3 "twemoji-${version}/assets/svg"
  # https://github.com/radicle-dev/radicle-interface/blob/master/package-lock.json
  #   "node_modules/twemoji": {
  #     "version": "14.0.2",
  # https://github.com/twitter/twemoji
  # 15 MB svg images
  # store as separate derivation
  twitter-emoji-svg = stdenv.mkDerivation rec {
    pname = "twitter-emoji-svg";
    version = "14.0.2";
    src = fetchFromGitHub {
      owner = "twitter";
      repo = "twemoji";
      rev = "v${version}";
      hash = "sha256-YoOnZ5uVukzi/6bLi22Y8U5TpplPzB7ji42l+/ys5xI=";
    };
    installPhase = ''
      cp -r $src/assets/svg $out
    '';
  };

  preBuild = ''
    # fix: sh: line 1: scripts/copy-katex-assets: cannot execute: required file not found
    echo patching shebangs of scripts
    patchShebangs scripts

    # fix: scripts/install-twemoji-assets: line 8: curl: command not found
    echo installing twitter-emoji-svg assets
    rm public/twemoji/.gitkeep
    rmdir public/twemoji
    ln -s -v ${twitter-emoji-svg} public/twemoji
    echo >scripts/install-twemoji-assets
  '';

  installPhase = ''
    cp -r build $out
  '';

  node_modules_attrs = {

    # fix: error: path '/nix/store/683zi3g8a2qd490lyvgrbz94yccmsbkb-source.drv' is not valid
    packageJson = ./package.json;
    packageLockJson = ./package-lock.json;

    nativeBuildInputs = [
      jq
    ];
    # remove the postinstall script
    # the same commands are called later in the build script
    # https://github.com/radicle-dev/radicle-interface/blob/master/package.json
    # {
    #   "version": "1.0.0",
    #   "scripts": {
    #     "build": "vite build && scripts/copy-katex-assets && scripts/install-twemoji-assets",
    #     "postinstall": "scripts/copy-katex-assets && scripts/install-twemoji-assets",
    preBuild = ''
      echo removing postinstall script from package.json
      cat package.json | jq 'del(.scripts.postinstall)' >package.json.new
      rm package.json
      mv package.json.new package.json
    '';
  };

  meta = with lib; {
    description = "Radicle web interface";
    homepage = "https://github.com/radicle-dev/radicle-interface";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
  };
}
