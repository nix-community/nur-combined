{
  sources,
  lib,
  rustPlatform,
  cmake,
  mkl,
  pcre2,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  inherit (sources.mtranservercore-rs) pname version src;

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    mkl
    pcre2
  ];

  patches = [
    # https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/by-name/tr/translatelocally/version_without_git.patch
    ./version_without_git.patch
  ];

  postPatch = ''
    echo '#define GIT_REVISION "${sources.mtranservercore-rs.rawVersion} ${finalAttrs.version}"' > \
      bergamot/bergamot-translator/3rd_party/marian-dev/src/common/git_revision.h

    substituteInPlace bergamot/build.rs \
      --replace-fail "mkl-static-ilp64-iomp" "mkl-dynamic-ilp64-iomp"
  '';

  postFixup = ''
    mv $out/bin/server $out/bin/${finalAttrs.pname}
  '';

  cargoHash = "sha256-lMHaSkOF7v7Sbe8CaSxfcD61BcKSuk9e0LGQeiYPe7U=";
  useFetchCargoVendor = true;

  env.MKLROOT = "${mkl}";

  meta = {
    mainProgram = finalAttrs.pname;
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Lightweight multilingual translation service based on Rust and Bergamot translation engine, compatible with multiple translation frontend APIs";
    homepage = "https://github.com/LinguaSpark/server";
    license = lib.licenses.agpl3Only;
  };
})
