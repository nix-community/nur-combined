{
  stdenv,
  fetchurl,
  nodejs,
  python3,
  electron,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "better-sqlite3-multiple-ciphers";
  version = "12.9.0";

  src = fetchurl {
    url = "https://registry.npmjs.org/better-sqlite3-multiple-ciphers/-/better-sqlite3-multiple-ciphers-${finalAttrs.version}.tgz";
    hash = "sha256-JOG0dBme1e/UljXjxOXdtHZEQ4fQGvDFMTLliwPbYCA=";
    downloadToTemp = true;
    recursiveHash = true;
    postFetch = ''
      mkdir -p $out
      tar -xzf $downloadedFile -C $out --strip-components=1
    '';
  };

  nativeBuildInputs = [
    nodejs
    python3
  ];

  buildPhase = ''
    runHook preBuild

    export npm_config_nodedir=${electron.headers}
    node ${nodejs}/lib/node_modules/npm/node_modules/node-gyp/bin/node-gyp.js rebuild --release

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 build/Release/better_sqlite3.node $out/lib/better_sqlite3.node

    runHook postInstall
  '';
})
