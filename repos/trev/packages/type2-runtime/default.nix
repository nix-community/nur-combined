{
  fetchFromGitHub,
  fuse3,
  lib,
  lz4,
  lzo,
  nix-update-script,
  squashfuse,
  xz,
  zlib,
  zstd,
  pkg-config,
  stdenv,
}:
let
  squashfuse' = squashfuse.overrideAttrs (old: {
    postInstall = (old.postInstall or "") + ''
      cp *.h -t $out/include/squashfuse/
    '';
  });
in
stdenv.mkDerivation (finalAttrs: {
  pname = "appimage-type2-runtime";
  version = "unstable-2026-03-07";

  src = fetchFromGitHub {
    owner = "AppImage";
    repo = "type2-runtime";
    rev = "3d17002ee2a519a288e28aeb7bc41af5f5adaf4e";
    hash = "sha256-fef5fnidXMvpkLWQISliI4tZqYb/C0PWWC1+jHMIn/Q=";
  };

  sourceRoot = "${finalAttrs.src.name}/src/runtime";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [
    fuse3
    squashfuse'
    zstd
    zlib
    xz
    lz4
    lzo
  ];

  configurePhase = ''
    $PKG_CONFIG --cflags fuse3 > cflags
  '';

  buildPhase = ''
    build=$(mktemp)

    $CC runtime.c -o $build \
      -D_FILE_OFFSET_BITS=64 -DGIT_COMMIT='"0000000"' \
      $(cat cflags) \
      -std=gnu99 -Os -ffunction-sections -fdata-sections -Wl,--gc-sections -static -Wall -Werror \
      -lsquashfuse -lsquashfuse_ll -lfuse3 -lzstd -lz -llzma -llz4 -llzo2 \
      -T data_sections.ld

    # Add AppImage Type 2 Magic Bytes to runtime
    printf %b '\x41\x49\x02' > magic_bytes
    dd if=magic_bytes of=$build bs=1 count=3 seek=8 conv=notrunc status=none
  '';

  installPhase = ''
    mkdir -p $out/bin
    mv $build $out/bin/runtime
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--commit"
      "--version=branch=main"
      finalAttrs.pname
    ];
  };

  meta = {
    mainProgram = "runtime";
    description = "AppImage Type 2 runtime";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    homepage = "https://github.com/AppImage/type2-runtime";
    changelog = "https://github.com/AppImage/type2-runtime/commits/${finalAttrs.src.rev}/";
  };
})
