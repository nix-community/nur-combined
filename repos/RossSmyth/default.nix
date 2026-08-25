{ ... }@args:
let
  pkgs =
    args.pkgs or (import <nixpkgs> {
      config.microsoftVisualStudioLicenseAccepted = true;
      overlays = [
        (import inputs.rust-overlay)
        (import inputs.qmix).overlays.default
      ];
    });

  inputs = import ./npins { };

  stable = import inputs."nixos-25.11" { };
in
pkgs.lib.makeScope pkgs.newScope (
  self:
  let
    inherit (self) callPackage;
  in
  {
    appimagetool = callPackage ./appimagetool { };
    buildAppImage = callPackage ./buildAppImage { };

    audiomoth-config = callPackage ./audiomoth-config { };
    audiomoth-flash = callPackage ./audiomoth-flash { };

    birdnet = self.python3Packages.callPackage ./birdnet { };
    birdnet-analyzer = self.callPackage ./birdnet-analyzer { };

    c2rust =
      let
        # c2rust requires an old (2022) nightly
        old-rust = pkgs.extend (import inputs.rust-overlay-2022);
      in
      old-rust.callPackage ./c2rust { };

    # chainner = callPackage ./chainner { };

    clang-cl = callPackage ./clang-cl { };

    jqjq = callPackage ./jqjq { };

    lily58-firmware = callPackage ./lily58 { };

    microcad = callPackage ./microcad { };

    msvcRust = callPackage ./msvc-rust {
      rustc =
        pkgs.rust-bin.stable.latest.minimal.override
          or (throw "requires rust-overlay to get windows-msvc std")
          { targets = [ "x86_64-pc-windows-msvc" ]; };
    };

    python3Packages = stable.python3Packages.overrideScope (
      _: _: {
        inherit (self) birdnet;
      }
    );
  }
)
