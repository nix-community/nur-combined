{
    description = "Instant Eyedropper Reborn — pixel-perfect color picker for Wayland, X11 & Windows";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
        rust-overlay.url = "github:oxalica/rust-overlay";
    };

    outputs = { self, nixpkgs, rust-overlay, ... }:
    let
        system = "x86_64-linux";
        pkgs = import nixpkgs {
            inherit system;
            overlays = [ (import rust-overlay) ];
            # ie-r itself is unfree (custom IE-R License); needed since meta declares licenses.unfree
            config.allowUnfree = true;
        };

        # ── Project metadata ─────────────────────────────────────────────────
        version = "0.1.2";  # single source of truth — also referenced in assets/installer.nsi

        # ── Toolchain ────────────────────────────────────────────────────────
        rustToolchain = pkgs.rust-bin.stable.latest.default.override {
            extensions = [ "rust-src" "rust-analyzer" ];
            targets = [ "x86_64-pc-windows-gnu" ];
        };

        rustPlatform = pkgs.makeRustPlatform {
            cargo = rustToolchain;
            rustc = rustToolchain;
        };

        # ── Dependencies ─────────────────────────────────────────────────────
        nativeDeps = with pkgs; [ pkg-config llvmPackages.libclang patchelf ];

        runtimeLibs = with pkgs; [
            libxkbcommon    # only directly-linked lib; smithay-client-toolkit evdev→Keysym + layout for Wayland keyboard
            wayland         # wayland-sys dlopen's libwayland-client.so — compositor socket entry point (WAYLAND_DISPLAY)
            dbus            # D-Bus session bus; KWin ScreenShot2 API (Tier 1 capture), SNI tray, dbusmenu protocol
            fontconfig      # fontdb+fontconfig-parser reads /etc/fonts/fonts.conf for system font directory discovery
            libx11          # x11-dl dlopen's libX11.so — X11 connector window management + XCB bridge (XWayland path)
            libxcursor      # x11-dl dlopen's libXcursor.so — cursor shapes for X11 overlay (Crosshair/Default/None)
            libxrandr       # x11-dl dlopen's libXrandr.so — monitor geometry in X11 connector
            libxi           # x11-dl dlopen's libXi.so — XInput2 pointer events + XGrabKey for global hotkeys
        ];

        libclangPath = "${pkgs.llvmPackages.libclang.lib}/lib";

        # ── Shared distribution helpers ────────────────────────────────────
        # Helper: emit shell commands to copy LICENSE/PRIVACY/SECURITY into dest dir.
        # Used by all three distribution paths (windows-installer, windows-bundle, portable).
        # README is intentionally NOT included — it's platform-specific.
        copyCommonDocs = dest: '' # bash
            cp ${./LICENSE}          "${dest}/LICENSE"
            cp ${./docs/PRIVACY.md}  "${dest}/PRIVACY.md"
            cp ${./docs/SECURITY.md} "${dest}/SECURITY.md"
        '';

        # ── Windows: cross-toolchain + apps (windows-installer, windows-bundle) ──
        windows = import ./nix/windows.nix {
            inherit pkgs version rustToolchain copyCommonDocs;
        };
        inherit (windows) mingwCC mingwPthreads;

        # ── Linux: portable, appimage, bundle, postinstall ────────────────
        defaultPkg = pkgs.callPackage ./nix/package.nix { inherit rustPlatform version; };
        linux = import ./nix/linux.nix {
            inherit pkgs version copyCommonDocs defaultPkg;
        };

    in {
        # ── Dev Environment ──────────────────────────────────────────────────
        devShells.${system}.default = pkgs.mkShell {
            nativeBuildInputs = [ mingwCC ];
            buildInputs = [ rustToolchain ] ++ nativeDeps ++ runtimeLibs;
            LIBCLANG_PATH = libclangPath;
            LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath runtimeLibs;
            CARGO_TARGET_X86_64_PC_WINDOWS_GNU_LINKER = "${mingwCC}/bin/x86_64-w64-mingw32-gcc";
            CARGO_TARGET_X86_64_PC_WINDOWS_GNU_RUSTFLAGS = "-L ${mingwPthreads}/lib";

            shellHook = '' # bash
                echo -e "\033[1;32mIE-R\033[0m Command Center Active"
                echo -e "\033[0;90mRust: $(rustc --version)\033[0m"
            '';
        };

        # ── Commands & Apps ──────────────────────────────────────────────────
        apps.${system} = {
            default  = { type = "app"; program = "${self.packages.${system}.default}/bin/ie-r"; meta.description = "Run IE-R color picker"; };
            appimage = linux.appimage-export;

            # Windows installer — run with: nix run .#windows-installer
            # Self-contained: builds exe + assembles bundle + runs NSIS
            # Produces: builds/ie-r-vVERSION-windows-x86_64-setup.exe
            windows-installer = windows.installer;

            # Windows portable bundle — run with: nix run .#windows-bundle
            # Produces: builds/ie-r-vVERSION-windows-x86_64-portable.zip → {ie-r.exe, fonts/, LICENSE, README.md, PRIVACY.md, SECURITY.md}
            windows-bundle = windows.bundle;

            # The "Divine Distributor" — wraps .#portable into builds/ie-r-vVERSION-linux-x86_64-portable.zip
            bundle = linux.bundle;
        };

        # ── Packages ─────────────────────────────────────────────────────────
        # portable, appimage → nix/linux.nix
        packages.${system} = {
            default  = defaultPkg;
            portable = linux.portable;
            appimage = linux.appimage;
        };
    };
}
