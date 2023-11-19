# based on https://github.com/NixOS/nixpkgs/blob/master/pkgs/tools/archivers/7zz/default.nix

{ stdenv
, lib
, fetchurl

  # Only used for Linux's x86/x86_64
, uasm
, useUasm ? (stdenv.isLinux && stdenv.hostPlatform.isx86)

  # RAR code is under non-free unRAR license
  # see the meta.license section below for more details
, enableUnfree ? false

  # For tests
, sevenzip
, testers
}:

stdenv.mkDerivation rec {

  # TODO what is better?
  #pname = "sevenzip";
  #pname = "7zip";
  pname = "7z";

  version = "23.01";

  src = fetchurl rec {
    name = "7z${lib.replaceStrings [ "." ] [ "" ] version}-src.tar.xz";
    urls = [
      "https://downloads.sourceforge.net/project/sevenzip/7-Zip/${version}/${name}"
      "https://7-zip.org/a/${name}"
    ];
    hash = {
      free = "sha256-7xMTG+kYMwbu6s7cdNgQYYMFig6sp/4KBSVIXw1VanM=";
      unfree = "sha256-NWBxAHNg5aGCTZkEmT6LJIC1G1cOjJ+vfA9Y6+S/n3Q=";
    }.${if enableUnfree then "unfree" else "free"};
    downloadToTemp = (!enableUnfree);
    # remove the unRAR related code from the src drv
    # > the license requires that you agree to these use restrictions,
    # > or you must remove the software (source and binary) from your hard disks
    # https://fedoraproject.org/wiki/Licensing:Unrar
    postFetch = lib.optionalString (!enableUnfree) ''
      mkdir tmp
      tar xf $downloadedFile -C ./tmp
      rm -r ./tmp/CPP/7zip/Compress/Rar*
      tar cfJ $out -C ./tmp . \
        --sort=name \
        --mtime="@$SOURCE_DATE_EPOCH" \
        --owner=0 --group=0 --numeric-owner \
        --pax-option=exthdr.name=%d/PaxHeaders/%f,delete=atime,delete=ctime
    '';
  };

  # the build does not produce any manpages
  # the debian version of 7zip has some manpages
  # https://salsa.debian.org/debian/7zip/-/tree/master/debian/man
  # https://manpages.debian.org/unstable/7zip/7zz.1
  # but they contain the same info as "7z --help" etc

  # fix: unpacker produced multiple directories
  sourceRoot = ".";

  # FIXME patches fail
  /*
  patches = [
    ./fix-build-on-darwin.patch
    ./fix-cross-mingw-build.patch
  ];
  patchFlags = [ "-p0" ];

  postPatch = lib.optionalString stdenv.hostPlatform.isMinGW ''
    substituteInPlace CPP/7zip/7zip_gcc.mak C/7zip_gcc_c.mak \
      --replace windres.exe ${stdenv.cc.targetPrefix}windres
  '';
  */

  # TODO remove?
  /*
  env.NIX_CFLAGS_COMPILE = toString (lib.optionals stdenv.isDarwin [
    "-Wno-deprecated-copy-dtor"
  ] ++ lib.optionals stdenv.hostPlatform.isMinGW [
    "-Wno-conversion"
    "-Wno-unused-macros"
  ]);
  */

  makeBundleNames = [
    "Alone"
    "Alone2"
    "Alone7z"
    "Format7zF"
  ];

  makeFlags =
    [
      "CC=${stdenv.cc.targetPrefix}cc"
      "CXX=${stdenv.cc.targetPrefix}c++"
      "PLATFORM=${
        if stdenv.hostPlatform.isx86_64 then "x64" else
        if stdenv.hostPlatform.isx86_32 then "x86" else
        if stdenv.hostPlatform.isAarch64 then "arm64" else
        if stdenv.hostPlatform.isArmv7 then "arm" else
        ""
      }"
      "IS_X64=${if stdenv.hostPlatform.isx86_64 then "1" else ""}"
      "IS_X86=${if stdenv.hostPlatform.isx86_32 then "1" else ""}"
      "IS_ARM64=${if stdenv.hostPlatform.isAarch64 then "1" else ""}"
    ]
    ++ [ "MY_ASM=${if useUasm then "uasm" else ""}" ]
    # We need at minimum 10.13 here because of utimensat, however since
    # we need a bump anyway, let's set the same minimum version as the one in
    # aarch64-darwin so we don't need additional changes for it
    ++ lib.optionals stdenv.isDarwin [ "MACOSX_DEPLOYMENT_TARGET=10.16" ]
    # it's the compression code with the restriction, see DOC/License.txt
    ++ lib.optionals (!enableUnfree) [ "DISABLE_RAR_COMPRESS=true" ]
    ++ lib.optionals (stdenv.hostPlatform.isMinGW) [ "IS_MINGW=1" "MSYSTEM=1" ]
  ;

  nativeBuildInputs = lib.optionals useUasm [ uasm ];

  enableParallelBuilding = true;

  buildPhase = ''
    for bundle in $makeBundleNames; do
      make -C CPP/7zip/Bundles/$bundle -f makefile.gcc $makeFlags
    done
  '';

  installPhase = ''
    runHook preInstall

    rm CPP/7zip/Bundles/*/_o/*.o

    # 7z.so
    install -Dm755 -t $out/lib CPP/7zip/Bundles/*/_o/*.so
    rm CPP/7zip/Bundles/*/_o/*.so

    # 7za 7zz 7zr
    install -Dm755 -t $out/bin CPP/7zip/Bundles/*/_o/*

    install -Dm644 -t $out/share/licenses/${pname} \
      DOC/{copying.txt,License.txt}
    rm DOC/{copying.txt,License.txt}

    ${if enableUnfree then ''
      install -Dm644 -t $out/share/licenses/${pname} DOC/unRarLicense.txt
      rm DOC/unRarLicense.txt
    '' else ""}

    install -Dm644 -t $out/share/doc/${pname} DOC/*

    runHook postInstall
  '';

  passthru = {
    updateScript = ./update.sh;
    tests.version = testers.testVersion {
      package = sevenzip;
      command = "7z --help";
    };
  };

  meta = with lib; {
    description = "Command line archiver utility";
    homepage = "https://7-zip.org";
    license = with licenses;
      # 7zip code is largely lgpl2Plus
      # CPP/7zip/Compress/LzfseDecoder.cpp is bsd3
      [ lgpl2Plus /* and */ bsd3 ] ++
      # and CPP/7zip/Compress/Rar* are unfree with the unRAR license restriction
      # the unRAR compression code is disabled by default
      lib.optionals enableUnfree [ unfree ];
    maintainers = with maintainers; [ anna328p peterhoeg jk ];
    platforms = platforms.unix ++ platforms.windows;
    mainProgram = "7z";
  };
}
