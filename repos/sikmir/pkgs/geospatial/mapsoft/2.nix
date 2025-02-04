{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  substituteAll,
  desktopToDarwinBundle,
  db,
  fig2dev,
  giflib,
  gsettings-desktop-schemas,
  gtkmm3,
  imagemagick,
  jansson,
  curl,
  libiconv,
  libjpeg,
  libpng,
  librsvg,
  libtiff,
  libxml2,
  libzip,
  perlPackages,
  pkg-config,
  proj,
  shapelib,
  sqlite,
  unzip,
  wrapGAppsHook,
}:

let
  libs = fetchFromGitHub {
    owner = "slazav";
    repo = "mapsoft2-libs";
    rev = "85241c6db623c95c36fc891e413444153739c373";
    hash = "sha256-Lu4HwszvTnXXGZl5Gs1vNKM4Ww7IY6fpY/Ozf07t3u4=";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "mapsoft2";
  version = "2.9-alt1-unstable-2025-01-29";

  src = fetchFromGitHub {
    owner = "slazav";
    repo = "mapsoft2";
    rev = "f97b0f3e41e50398ab135b6a96047ff497ae6b94";
    hash = "sha256-STXA7/hhm3/fK6WnrYNezymVxUHaKfPdg1Z9kjBeZsQ=";
  };

  prePatch = ''
    cp -r ${libs}/* modules
    chmod -R +w modules
  '';

  patches = [
    # https://github.com/slazav/mapsoft2-libs/commit/c0c13a537d4aa6f8d8af530f29408a0ae8c5512c#r152084247
    (fetchpatch {
      url = "https://github.com/slazav/mapsoft2-libs/commit/c0c13a537d4aa6f8d8af530f29408a0ae8c5512c.patch";
      hash = "sha256-uTJnLPwPupUy3c8zr/nx87lA97YQKhQ1nQsr3ltOUE8=";
      revert = true;
      stripLen = 1;
      extraPrefix = "modules/";
    })
    ./0002-fix-build.patch
  ] ++ lib.optional (!finalAttrs.doCheck) ./0003-notests.patch;

  postPatch =
    let
      srcFiles = [
        "docs/man/ms2render.htm"
        "docs/man/ms2view.htm"
        "docs/man/ms2view.txt"
        "docs/man/ms2vmap.htm"
        "docs/man/ms2vmapdb.htm"
        "modules/mapview/action_manager.cpp"
        "modules/mapview/mapview.cpp"
        "modules/vmap2/vmap2gobj.cpp"
        "modules/vmap2/vmap2types.cpp"
        "vmap_data/scripts/vmaps.sh"
        "vmap_data/scripts/vmaps_diff"
        "vmap_data/scripts/vmaps_get_fig"
        "vmap_data/scripts/vmaps_img"
        "vmap_data/scripts/vmaps_in"
        "vmap_data/scripts/vmaps_index"
        "vmap_data/scripts/vmaps_out"
        "vmap_data/scripts/vmaps_pack_img"
        "vmap_data/scripts/vmaps_pack_mbtiles"
        "vmap_data/scripts/vmaps_pack_sqlitedb"
        "vmap_data/scripts/vmaps_png"
        "vmap_data/scripts/vmaps_preview"
        "vmap_data/scripts/vmaps_rend_mbtiles"
        "vmap_data/scripts/vmaps_tiles"
        "vmap_data/scripts/vmaps_tlist"
        "vmap_data/scripts/vmaps_wp_update"
      ];
    in
    ''
      ${lib.concatStringsSep "\n" (map (file: ''substituteInPlace ${file} --subst-var out'') srcFiles)}

      substituteInPlace modules/opt/Makefile --replace-fail "SIMPLE_TESTS := opt" ""
      substituteInPlace modules/tmpdir/Makefile --replace-fail "SCRIPT_TESTS := tmpdir" ""
      substituteInPlace modules/get_deps --replace-fail "/usr/bin/perl" "${perlPackages.perl}/bin/perl"
      patchShebangs .
    '';

  nativeBuildInputs = [
    fig2dev
    imagemagick
    perlPackages.perl
    pkg-config
    unzip
    wrapGAppsHook
  ] ++ lib.optional stdenv.isDarwin desktopToDarwinBundle;

  buildInputs = [
    db
    giflib
    gsettings-desktop-schemas
    gtkmm3
    jansson
    curl
    libjpeg
    libpng
    librsvg
    libtiff
    libxml2
    libzip
    proj
    shapelib
    sqlite
  ] ++ lib.optional stdenv.hostPlatform.isDarwin libiconv;

  env = {
    SKIP_IMG_DIFFS = 1;
    NIX_CFLAGS_COMPILE = "-std=c++17";
    NIX_LDFLAGS = lib.optionalString stdenv.hostPlatform.isDarwin "-liconv";
  };

  enableParallelBuilding = true;

  makeFlags = [ "prefix=$(out)" ];

  doCheck = true;

  dontWrapGApps = true;

  postFixup = ''
    for f in $out/bin/ms2*; do
      wrapGApp $f
    done
  '';

  meta = {
    description = "A collection of tools and libraries for working with maps and geo-data";
    homepage = "http://slazav.github.io/mapsoft2";
    license = lib.licenses.gpl3;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
    skip.ci = true;
  };
})
