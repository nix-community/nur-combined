{
  sources,
  lib,
  stdenv,
  cmake,
  mkl,
  pcre2,
}:
let
  mklStatic = mkl.override { enableStatic = true; };
in
stdenv.mkDerivation (finalAttrs: {
  inherit (sources.linguaspark-core) pname version src;
  sourceRoot = "source/linguaspark";
  enableParallelBuilding = true;

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    mklStatic
    pcre2
  ];

  prePatch = ''
    mkdir -p 3rd_party
    cp -r ${sources.bergamot-translator.src} 3rd_party/bergamot-translator
    chmod -R +w 3rd_party/bergamot-translator
  '';

  patches = [
    # https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/by-name/tr/translatelocally/version_without_git.patch
    ./version_without_git.patch
  ];

  postPatch = ''
    echo '#define GIT_REVISION "${sources.linguaspark-core.rawVersion} ${finalAttrs.version}"' > \
      3rd_party/bergamot-translator/3rd_party/marian-dev/src/common/git_revision.h
  '';

  env.MKLROOT = "${mklStatic}";

  makeFlags = [ "linguaspark" ];

  installPhase = ''
    runHook preInstall

    install -Dm755 liblinguaspark.so $out/lib/liblinguaspark.so

    runHook postInstall
  '';

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "LinguaSpark Core";
    homepage = "https://github.com/LinguaSpark/core";
    license = lib.licenses.agpl3Only;
    inherit (mklStatic.meta) platforms;
  };
})
