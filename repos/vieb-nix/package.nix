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
  version = "12.5.0";

  src = fetchFromGitHub {
    owner = "Jelmerro";
    repo = "vieb";
    rev = finalAttrs.version;
    hash = "sha256-5Fr7/LoKYJVQHL/tv5OkOPhuQJUgGHa7rtVkdVXpk6Q=";
  };

  postPatch = ''
    sed -i '/"electron"/d' package.json
  '';

  npmDepsHash = "sha256-A32UKFT3CPM503aLQnJ3NKRMnsr8wReWmSh+7sUe5yQ=";
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
      desktopName = "Web Browser";
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
