{
  stdenv,
  buildNpmPackage,
  fetchFromGitHub,
  electron,
  makeWrapper,
  python3,
  makeDesktopItem,
  copyDesktopItems,
  lib,
}:

buildNpmPackage (finalAttrs: {
  pname = "vieb";
  version = "12.8.0";

  src = fetchFromGitHub {
    owner = "Jelmerro";
    repo = "vieb";
    rev = finalAttrs.version;
    hash = "sha256-J+LXUQ/COeoYFTC1pL1/Eo23ZLjTSJ3m6DjDp3ROFeI=";
  };

  postPatch = ''
    sed -i '/"electron"/d' package.json
  '';

  npmDepsHash = "sha256-3M2XnRf2sWdj0Pq02ohHP6JpckM3OCb6ozWJSi6P5aU=";
  makeCacheWritable = true;
  dontNpmBuild = true;
  env.ELECTRON_SKIP_BINARY_DOWNLOAD = 1;

  nativeBuildInputs = [
    makeWrapper
    copyDesktopItems
  ] ++ lib.optional stdenv.isAarch64 python3;

  desktopItems = [
    (makeDesktopItem {
      name = "vieb";
      exec = "vieb %U";
      icon = "vieb";
      desktopName = "Vieb";
      genericName = "Web Browser";
      categories = [ "Network" "WebBrowser" ];
      mimeTypes = [
        "text/html"
        "application/xhtml+xml"
        "x-scheme-handler/http"
        "x-scheme-handler/https"
      ];
    })
  ];

  postInstall = ''
    pushd $out/lib/node_modules/vieb/app/img/icons
    for file in *.png; do
      install -Dm0644 $file $out/share/icons/hicolor/''${file//.png}/apps/vieb.png
    done
    popd

    makeWrapper ${electron}/bin/electron $out/bin/vieb \
      --add-flags $out/lib/node_modules/vieb/app \
      --set npm_package_version ${finalAttrs.version}
  '';

  distPhase = ":"; # disable useless $out/tarballs directory

  meta = {
    homepage = "https://vieb.dev/";
    changelog = "https://github.com/Jelmerro/Vieb/releases/tag/${finalAttrs.version}";
    description = "Vim Inspired Electron Browser";
    platforms = lib.platforms.unix;
    license = lib.licenses.gpl3Plus;
    mainProgram = "vieb";
  };
})
