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

  # The UEFI image is built freestanding, without mingw's CRT or default
  # libraries.  FreeType needs a real setjmp/longjmp for its raster-overflow and
  # validator recovery paths; setjmp.S saves the full Windows x64 jmp_buf
  # state.  compat.cpp supplies the libc string entry points and the non-va_list
  # printf aliases referenced by FreeType/HarfBuzz (the va_list formatting
  # backends remain upstream's deliberate stubs).
  postPatch = ''
    cp ${./compat.cpp} src/compat.cpp
    cp ${./setjmp.S} src/setjmp.S
  '';

  cmakeFlags = [
    "-DCMAKE_TOOLCHAIN_FILE=../mingw-amd64.cmake"
    "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
    "-DCMAKE_C_STANDARD_LIBRARIES="
    "-DCMAKE_CXX_STANDARD_LIBRARIES="
  ];

  installPhase = ''
    runHook preInstall

    install -Dm644 quibble.efi $out/share/quibble/quibble.efi
    install -Dm644 btrfs/btrfs.efi $out/share/quibble/drivers/btrfs.efi
    install -Dm644 ntfs/ntfs.efi $out/share/quibble/drivers/ntfs.efi
    install -Dm644 ${src}/README.md $out/share/quibble/README.md
    install -Dm644 ${src}/LICENCE $out/share/quibble/LICENCE

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
    homepage = "https://github.com/maharmstone/quibble";
    license = lib.licenses.lgpl3Only;
    # hostPlatform is Windows when cross-compiling; omit platforms so nixpkgs
    # does not reject this nested drv during the native package-set eval.
  };
}
