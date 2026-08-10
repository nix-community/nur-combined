{
  lib,
  stdenv,
  sources,
  fetchurl,
  nodejs_24,
  pnpm_10,
  fetchPnpmDeps,
  pnpmConfigHook,
  makeWrapper,
  patchelf,
  python3,
}:
let
  sassEmbedded = fetchurl {
    url = "https://registry.npmmirror.com/sass-embedded-linux-x64/-/sass-embedded-linux-x64-1.100.0.tgz";
    hash = "sha256-a0Nc3UlTvYkZ+0BGq7G2BKrb5+hrxA8dNxDKv8VvMCY=";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "nexus-media-web";
  inherit (sources.nexus-media-web) version src;

  pnpmDeps = fetchPnpmDeps {
    pname = "nexus-media-web-pnpm-deps";
    inherit (finalAttrs) version src;
    pnpm = pnpm_10;
    fetcherVersion = 3;
    pnpmInstallFlags = [ "--registry=https://registry.npmmirror.com" ];
    prePnpmInstall = ''
      sed -i 's|"pnpm": ">=11.0.0"|"pnpm": ">=10.0.0"|' package.json
      sed -i 's|"packageManager": "pnpm@11.8.0"|"packageManager": "pnpm@10.34.5"|' package.json
      echo 'registry=https://registry.npmmirror.com' >> .npmrc
      if [ -n "''${https_proxy:-}" ]; then
        PROXY=$(printf '%s' "$https_proxy" | sed 's|^socks5://|socks5h://|')
        echo "proxy=$PROXY" >> .npmrc
        echo "https-proxy=$PROXY" >> .npmrc
      fi
    '';
    hash = "sha256-UvpWhZMQlneqWgzkmkAAiQ4ysczUEIWUlLNuHhyu1Sc=";
  };

  nativeBuildInputs = [
    nodejs_24
    pnpmConfigHook
    pnpm_10
    makeWrapper
    patchelf
    python3
  ];

  env.CI = "true";
  env.NODE_OPTIONS = "--max-old-space-size=4096";

  postPatch = ''
    sed -i 's|"pnpm": ">=11.0.0"|"pnpm": ">=10.0.0"|' package.json
    sed -i 's|"packageManager": "pnpm@11.8.0"|"packageManager": "pnpm@10.34.5"|' package.json
  '';

  preBuild = ''
    pnpm -r run stub --if-present

    mkdir -p /tmp/sass-embedded
    tar -xzf ${sassEmbedded} -C /tmp/sass-embedded
    SASS_DIR="node_modules/.pnpm/sass-embedded-linux-x64@1.100.0/node_modules/sass-embedded-linux-x64"
    rm -rf "$SASS_DIR/dart-sass"
    cp -r /tmp/sass-embedded/package/dart-sass "$SASS_DIR/"
    chmod -R +x "$SASS_DIR/dart-sass"
    patchelf --set-interpreter "${stdenv.cc.libc}/lib/ld-linux-x86-64.so.2" \
      --set-rpath "${lib.makeLibraryPath [ stdenv.cc.cc.lib ]}" \
      "$SASS_DIR/dart-sass/src/dart"
  '';

  buildPhase = ''
    runHook preBuild
    pnpm run build:nexus
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp -r apps/nexus-media/dist/. $out/
    makeWrapper ${python3.interpreter} $out/bin/nexus-media-web \
      --add-flags "-m" \
      --add-flags "http.server" \
      --add-flags "''${PORT:-8080}" \
      --add-flags "--directory" \
      --add-flags "$out"
    runHook postInstall
  '';

  meta = {
    changelog = "https://github.com/linyuan0213/nexus-media-web/releases/tag/v${finalAttrs.version}";
    description = "Vue 3 web frontend for the Nexus Media media library manager";
    homepage = "https://github.com/linyuan0213/nexus-media-web";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    maintainers = [
      {
        github = "zhyiheihei";
        name = "zhyiheihei";
      }
    ];
    mainProgram = "nexus-media-web";
  };
})
