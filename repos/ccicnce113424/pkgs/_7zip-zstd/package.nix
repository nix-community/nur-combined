{
  lib,
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  uasm,
  asmc-linux,
  _experimental-update-script-combinators,
  nix-update-script,
  enableRar ? false,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "7zip-zstd";
  version = "25.01-v1.5.7-R4";

  src = fetchFromGitHub {
    owner = "mcmilk";
    repo = "7-Zip-zstd";
    tag = "v${finalAttrs.version}";
    hash =
      if enableRar then
        "sha256-qP4L5PIG7CHsmYbRock+cbCOGdgujUFG4LHenvvlqzw="
      else
        "sha256-R9AUWL35TPh0anyRDhnF28ZYG9FeOxntVIwnnW9e2xA=";
    # remove the unRAR related code from the src drv
    # > the license requires that you agree to these use restrictions,
    # > or you must remove the software (source and binary) from your hard disks
    # https://fedoraproject.org/wiki/Licensing:Unrar
    postFetch = lib.optionalString (!enableRar) ''
      rm -r $out/CPP/7zip/Compress/Rar*
    '';
  };

  nativeBuildInputs = [
    makeWrapper
  ]
  ++ lib.optional stdenv.hostPlatform.isx86 (
    if stdenv.hostPlatform.isLinux then asmc-linux else uasm
  );

  outputs = [
    "out"
    "doc"
  ];

  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
    "CXX=${stdenv.cc.targetPrefix}c++"
  ]
  ++ lib.optionals (stdenv.hostPlatform.isx86) [
    "MY_ASM=${if stdenv.hostPlatform.isLinux then "asmc" else "uasm"}"
  ]
  ++ lib.optionals (stdenv.hostPlatform.isx86 && stdenv.hostPlatform.isDarwin) [ "USE_ASM=1" ]
  ++ lib.optionals (!enableRar) [ "DISABLE_RAR_COMPRESS=true" ]
  ++ lib.optionals (stdenv.cc.isClang) [ "FLAGS_FLTO=-flto=thin" ]
  # ++ lib.optionals (stdenv.hostPlatform.isMinGW) [
  #   "IS_MINGW=1"
  #   "MSYSTEM=1"
  # ]
  ;

  enableParallelBuilding = true;

  postPatch = ''
    sed -i 's/-Werror//g' CPP/7zip/7zip_gcc.mak
  ''
  # + lib.optionalString stdenv.hostPlatform.isMinGW ''
  #   substituteInPlace CPP/7zip/7zip_gcc.mak C/7zip_gcc_c.mak \
  #     --replace windres.exe ${stdenv.cc.targetPrefix}windres
  # ''
  ;

  buildPhase =
    let
      makefile = "../../cmpl_${
        if stdenv.hostPlatform.isDarwin then
          "mac"
        else if stdenv.cc.isClang then
          "clang"
        else
          "gcc"
      }${
        if stdenv.isx86_64 then
          "_x64"
        else if stdenv.isAarch64 then
          "_arm64"
        else if stdenv.isi686 then
          "_x86"
        else
          ""
      }.mak";
    in
    ''
      runHook preBuild

      for component in Bundles/{Alone,Alone2,Alone7z,Format7zF,SFXCon} UI/Console; do
        make -j $NIX_BUILD_CORES -C CPP/7zip/$component -f ${makefile} $makeFlags
      done

      runHook postBuild
    '';

  installPhase =
    let
      inherit (stdenv.hostPlatform) extensions;
    in
    ''
      runHook preInstall

      install -Dt "$out/lib/7zip" \
        CPP/7zip/Bundles/Alone/b/*/7za${extensions.executable} \
        CPP/7zip/Bundles/Alone2/b/*/7zz${extensions.executable} \
        CPP/7zip/Bundles/Alone7z/b/*/7zr${extensions.executable} \
        CPP/7zip/Bundles/Format7zF/b/*/7z${extensions.sharedLibrary} \
        CPP/7zip/UI/Console/b/*/7z${extensions.executable}

      install -D CPP/7zip/Bundles/SFXCon/b/*/7zCon${extensions.executable} "$out/lib/7zip/7zCon.sfx"

      mkdir -p "$out/bin"
      for prog in 7za 7zz 7zr 7z; do
        makeWrapper "$out/lib/7zip/$prog${extensions.executable}" \
          "$out/bin/$prog${extensions.executable}"
      done

      install -Dt "$out/share/doc/7zip" DOC/*.txt

      runHook postInstall
    '';

  setupHook = ./setup-hook.sh;
  passthru.updateScript = _experimental-update-script-combinators.sequence [
    (nix-update-script {
      attrPath = "_7zip-zstd";
      extraArgs = [ "--use-github-releases" ];
    })
    (nix-update-script {
      attrPath = "_7zip-zstd-rar";
      extraArgs = [ "--version=skip" ];
    })
  ];

  meta = {
    homepage = "https://github.com/mcmilk/7-Zip-zstd";
    description = "7-Zip with support for Brotli, Fast-LZMA2, Lizard, LZ4, LZ5 and Zstandard";
    changelog = "https://github.com/mcmilk/7-Zip-zstd/releases/tag/v${finalAttrs.version}";
    license =
      with lib.licenses;
      # p7zip code is largely lgpl2Plus
      # CPP/7zip/Compress/LzfseDecoder.cpp is bsd3
      [
        lgpl2Plus # and
        bsd3
      ]
      ++
        # and CPP/7zip/Compress/Rar* are unfree with the unRAR license restriction
        # the unRAR compression code is disabled by default
        lib.optionals enableRar [ unfreeRedistributable ];
    maintainers = with lib.maintainers; [
      ccicnce113424
    ];
    platforms = lib.platforms.unix;
    mainProgram = "7z";
  };
})
