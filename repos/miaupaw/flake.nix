{
    description = "Instant Eyedropper Reborn - Universal Command Center...";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
        rust-overlay.url = "github:oxalica/rust-overlay";
    };

    outputs = { self, nixpkgs, rust-overlay, ... }:
    let
        system = "x86_64-linux";
        pkgs = import nixpkgs {
            inherit system;
            overlays = [ (import rust-overlay) ];
            config.allowUnfree = true;  # ie-r itself is unfree (custom IE-R License); needed since meta declares licenses.unfree
        };

        # ── Project metadata ─────────────────────────────────────────────────
        version = "0.1.1";  # single source of truth — also referenced in assets/installer.nsi

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

        libclangPath = "${pkgs.llvmPackages.libclang.lib}/lib";

        # ── Shared distribution helpers ────────────────────────────────────
        # Helper: emit shell commands to copy LICENSE/PRIVACY/SECURITY into dest dir.
        # Used by all three distribution paths (windows-installer, windows-bundle, portable).
        # README is intentionally NOT included — it's platform-specific.
        copyCommonDocs = dest: '' # bash
            cp ${./LICENSE}     "${dest}/LICENSE"
            cp ${./PRIVACY.md}  "${dest}/PRIVACY.md"
            cp ${./SECURITY.md} "${dest}/SECURITY.md"
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
            buildInputs = [ rustToolchain mingwCC mingwPthreads ] ++ nativeDeps ++ runtimeLibs;
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
            appimage = { type = "app"; program = "${self.packages.${system}.appimage}/ie-r-v${version}-x86_64.AppImage"; meta.description = "Build and run IE-R AppImage"; };

            # Windows installer — run with: nix run .#windows-installer
            # Self-contained: builds exe + assembles bundle + runs NSIS
            # Produces: ie-r-setup-vVERSION.exe
            windows-installer = windows.installer;

            # Windows portable bundle — run with: nix run .#windows-bundle
            # Produces: ie-r-portable-vVERSION.zip → {ie-r.exe, fonts/, LICENSE, README.md, PRIVACY.md, SECURITY.md}
            windows-bundle = windows.bundle;

            # The "Divine Distributor" — wraps .#portable into ie-r-vVERSION.zip
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
