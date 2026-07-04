{
  lib,
  buildGoModule,
  pkg-config,
  fetchYarnDeps,
  pkgs,
  ...
}:

pkgs.stdenv.mkDerivation rec {
  pname = "torrserver";
  version = "MatriX.142";

  src = pkgs.fetchgit {
    url = "https://github.com/YouROK/TorrServer.git";
    rev = "${version}";
    hash = "sha256-bAnnDbrKYfU3WdjwIW4GGDST4S13KIhGNoQQtI27UaQ=";
  };

  yarnOfflineCache = pkgs.fetchYarnDeps {
    yarnLock = "${src}/web/yarn.lock";
    hash = "sha256-YhRIR5mq7ZK4jqFsPvhOpEtDmIoiJVn3bRkpI6A4mqg=";
  };

  goModules = pkgs.buildGoModule.override { go = pkgs.go_1_26; } {
    pname = "torrserver-go-deps";
    version = version;
    src = "${src}/server";
    vendorHash = "sha256-B5BAmdFuLWDkbp/lehFziyHXcMPIAgNySgTPv9Nv680=";

    modBuildPhase = ''
      go mod download
      go mod vendor
    '';

    installPhase = ''
      mkdir -p $out
      cp -r vendor $out/
    '';

    doCheck = false;
    doInstallCheck = false;
    buildPhase = "true";
  };

  nativeBuildInputs = with pkgs; [
    go_1_26
    pkg-config
    git
    yarn
    fixup-yarn-lock
    nodejs
    go-swag
  ];

  buildInputs = with pkgs; [
    fuse
  ];

  buildPhase = ''
    export GOCACHE=$TMPDIR/go-build
    export GOMODCACHE=$TMPDIR/go-mod
    export HOME=$(mktemp -d)
    export NODE_OPTIONS=--openssl-legacy-provider
    export PATH=$PATH:$(go env GOPATH)/bin

    cd web
    runHook preConfigure
    yarn config --offline set yarn-offline-mirror ${yarnOfflineCache}
    fixup-yarn-lock yarn.lock
    yarn install --offline --frozen-lockfile --ignore-platform --ignore-scripts --no-progress --non-interactive
    patchShebangs node_modules/
    yarn build
    cd ..

    cd server
    swag init -g web/server.go --parseDependency --parseInternal --parseDepth 5
    cd ..

    mkdir -p server/vendor
    cp -r ${goModules}/vendor/* server/vendor/
    chmod -R +w server/vendor

    cd server
    mkdir -p ../dist
    GOOS=linux GOARCH=amd64 go build \
      -ldflags="-s -w -checklinkname=0" \
      -tags=nosqlite \
      -trimpath \
      -o ../dist/torrserver ./cmd
    cd ..
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp dist/torrserver $out/bin/torrserver
    chmod +x $out/bin/torrserver
  '';

  meta = with pkgs.lib; {
    description = "Simple and powerful tool for streaming torrents";
    homepage = "https://github.com/YouROK/TorrServer";
    license = licenses.gpl3Only;
    mainProgram = "torrserver";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
    ];
  };
}
