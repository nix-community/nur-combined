# ─────────────────────────────────────────────────────────────────────────────
#   2) nixpkgs:  callPackage ./pkgs/by-name/ie/ie-r/package.nix {}
# nix/package.nix — single source of truth for the ie-r build itself.
# callPackage-shaped signature → dual-use: flake (with rust-overlay rustPlatform)
# and nixpkgs (with stock rustPlatform). Both produce a sha256-identical binary.
# ─────────────────────────────────────────────────────────────────────────────
{ lib
, rustPlatform
, pkg-config
, llvmPackages
, patchelf
, pipewire
, wayland
, libxkbcommon
, dbus
, fontconfig
, libx11
, libxcursor
, libxrandr
, libxi
, jetbrains-mono
, version ? "0.1.1"
}:

let
  # Runtime shared libs the binary loads (some via dlopen — patchelf alone
  # would not pull them in, hence explicit makeLibraryPath in postFixup).
  runtimeLibs = [
    pipewire
    wayland
    libxkbcommon
    dbus
    fontconfig
    libx11
    libxcursor
    libxrandr
    libxi
  ];
in
rustPlatform.buildRustPackage {
  pname = "ie-r";
  inherit version;
  src = ../.;
  cargoLock.lockFile = ../Cargo.lock;

  # cargo test needs a display server / pipewire — not feasible in Nix sandbox
  doCheck = false;

  nativeBuildInputs = [ pkg-config llvmPackages.libclang patchelf ];
  buildInputs = runtimeLibs;

  # bindgen needs libclang at runtime to parse C headers (xkbcommon etc.)
  LIBCLANG_PATH = "${llvmPackages.libclang.lib}/lib";

  # Install non-program artifacts (icons, .desktop, fonts, license) and
  # rewrite the Exec= path inside the .desktop to the absolute $out path.
  postInstall = '' # bash
      install -Dm644 assets/ie-r.desktop -t $out/share/applications/
      install -Dm644 assets/ie-r.svg -t $out/share/icons/hicolor/scalable/apps/
      install -Dm644 assets/ie-r-symbolic.svg -t $out/share/icons/hicolor/symbolic/apps/
      install -Dm644 LICENSE -t $out/share/licenses/ie-r/
      install -Dm644 ${jetbrains-mono}/share/fonts/truetype/JetBrainsMono-Regular.ttf \
          -t $out/share/ie-r/fonts/
      install -Dm644 assets/fonts/OFL.txt -t $out/share/ie-r/fonts/
      substituteInPlace $out/share/applications/ie-r.desktop --replace-fail "Exec=ie-r" "Exec=$out/bin/ie-r"
  '';

  # Force-bake rpath so dlopen() finds X11/Wayland/Pipewire libs without LD_LIBRARY_PATH.
  postFixup = '' # bash
      patchelf --set-rpath "${lib.makeLibraryPath runtimeLibs}" $out/bin/ie-r
  '';

  meta = with lib; {
      description = "Instant Eyedropper Reborn — pixel-perfect color picker for Linux (Wayland & X11)";
      homepage    = "https://instant-eyedropper.com/linux/";
      license     = licenses.unfree;  # custom IE-R License v1.0 (free for personal/individual use)
      mainProgram = "ie-r";
      platforms   = [ "x86_64-linux" ];
      sourceProvenance = with sourceTypes; [ fromSource ];
  };
}
