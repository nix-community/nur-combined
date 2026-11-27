{
  lib,
  pkgsCross,
  fetchFromGitHub,
  cmake,
  ninja,
  gnu-efi,
  nix,
  nix-update-script,
  python3,
  writeShellApplication,
}:

let
  version = "20230328-unstable-2024-06-23";
  rev = "7402412537678e46f40613a7a4a73644a2d0f68c";
  mingw = pkgsCross.mingw-msvcrt-x86_64;
  src = fetchFromGitHub {
    owner = "maharmstone";
    repo = "quibble";
    inherit rev;
    fetchSubmodules = true;
    hash = "sha256-4xT7adK0v52coMvDPJ8nhXOyBWgMJ0o21R1QGRG4zZ4=";
  };

  # Upstream's own print.cpp already dummies the libc entry points FreeType and
  # HarfBuzz reference, so the image is built against those dummies.  Only the
  # three names that block does not cover need definitions, and they abort the
  # same way; they go in an archive so upstream's sources stay untouched.
  runtime = mingw.stdenv.mkDerivation {
    pname = "quibble-runtime";
    inherit version;
    dontUnpack = true;

    buildPhase = ''
      runHook preBuild
      $CXX -D_CRTIMP= -c ${./stubs.cpp} -o stubs.o -ffreestanding -fno-stack-protector -fno-exceptions
      $AR rcs libquibble-rt.a stubs.o
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      install -Dm644 libquibble-rt.a $out/lib/libquibble-rt.a
      runHook postInstall
    '';
  };
in
mingw.stdenv.mkDerivation {
  pname = "quibble";
  inherit version;
  inherit src;

  nativeBuildInputs = [
    cmake
    ninja
  ];

  # Upstream's CMakeLists looks for gnu-efi under /usr/include/efi, which is not
  # available in the build sandbox.
  NIX_CFLAGS_COMPILE = "-D_CRTIMP= -I${gnu-efi}/include/efi -I${gnu-efi}/include/efi/x86_64";

  hardeningDisable = [ "all" ];

  patches = [ ./nix.patch ];

  # Upstream's own preset; the freestanding link flags and the runtime archive
  # hook are part of nix.patch, so the toolchain file stays upstream's.
  cmakeFlags = [
    "-DCMAKE_TOOLCHAIN_FILE=../mingw-amd64.cmake"
    "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
    "-DQUIBBLE_RT_ARCHIVE=${runtime}/lib/libquibble-rt.a"
  ];

  installPhase = ''
    runHook preInstall

    install -Dm644 quibble.efi $out/share/quibble/quibble.efi
    install -Dm644 btrfs/btrfs.efi $out/share/quibble/drivers/btrfs.efi
    install -Dm644 ntfs/ntfs.efi $out/share/quibble/drivers/ntfs.efi
    install -Dm644 ${src}/README.md $out/share/quibble/README.md
    install -Dm644 ${src}/LICENCE $out/share/quibble/LICENCE
    install -Dm644 ${src}/font.ttf $out/share/quibble/font.ttf

    runHook postInstall
  '';

  passthru.updateScript = writeShellApplication {
    name = "update-quibble";
    runtimeInputs = [
      nix
      python3
    ];
    text = ''
      export UPDATE_NIX_ATTR_PATH="quibble"
      ${
        lib.escapeShellArgs (nix-update-script {
          extraArgs = [ "--version=branch" ];
        })
      } "$@"

      # Quibble has no release tags. Use the CMake project version as the
      # stable prefix instead of nix-update's fallback of 0.
      source_path=$(nix build .#quibble.src --no-link --print-out-paths)
      python3 - "$source_path" <<'PY'
      import pathlib
      import re
      import sys

      source = pathlib.Path(sys.argv[1])
      cmake = (source / "CMakeLists.txt").read_text()
      base = re.search(r"project\(quibble VERSION ([0-9.]+)\)", cmake).group(1)

      package = pathlib.Path("by-name/qu/quibble/package.nix")
      text = package.read_text()
      text = re.sub(
          r'(?m)^  version = "[^"]*-unstable-([0-9-]+)";',
          lambda m: f'  version = "{base}-unstable-{m.group(1)}";',
          text,
      )
      package.write_text(text)
      PY
    '';
  };

  meta = {
    description = "Open-source UEFI bootloader for Windows XP through Windows 10";
    longDescription = ''
      Quibble boots Windows XP through Windows 10 from UEFI.

      Installing it: the loader reads `freeldr.ini` and `font.ttf` from the
      directory the EFI image itself was loaded from, so `quibble.efi`,
      `freeldr.ini` and `font.ttf` have to sit together (for example
      `\EFI\BOOT\` with `quibble.efi` renamed to `BOOTX64.EFI`), with the
      `drivers/` directory next to them. Upstream's source tree ships no
      `freeldr.ini`; write one with a `[FREELOADER]` section and one
      `SystemPath=multi(0)disk(0)rdisk(0)partition(N)\Windows` entry per
      operating system.
    '';
    homepage = "https://github.com/maharmstone/quibble";
    license = lib.licenses.lgpl3Only;
    # hostPlatform is Windows when cross-compiling; omit platforms so nixpkgs
    # does not reject this nested drv during the native package-set eval.
  };
}
