/*
nix-build -E 'with import <nixpkgs> { }; callPackage ./default.nix { }'
*/

{ lib, fetchFromGitHub, rustPlatform, newScope }:

let
  version = "2022-07-26";
  xi-editor-src = fetchFromGitHub {
    owner = "xi-editor";
    repo = "xi-editor";
    rev = "c44e2bd011aed7c2d4d625b6a59bb2682a4654c0";
    sha256 = "sha256-N7OfFwUjb303LiOsM8koM5Xdi2gzF4t9b1ukygLnXEQ=";
  };
  callPackage = newScope self;
  self = {
    xi-core = rustPlatform.buildRustPackage {
      name = "xi-core-${version}";
      inherit version;

      src = xi-editor-src;

      sourceRoot = "source/rust";

      #cargoPatches = [ ./0001-only-use-one-version-of-syntect.patch ];

      cargoSha256 = "sha256-vSTZ4NdRg53ZYJWFfCX2TyhLvpB2ODy7APR9/ZdSEPg=";

      # syntect is slow (regex-based) syntax highlighting
      /*
      postInstall = ''
        make -C syntect-plugin install XI_PLUGIN_DIR=$out/share/xi/plugins
        ln -vrs $out/share/xi/plugins/syntect $syntect
      '';
      */

      #outputs = [ "out" "syntect" ];

      meta = with lib; {
        description = "A modern editor with a backend written in Rust";
        homepage = https://github.com/xi-editor/xi-editor;
        license = licenses.asl20;
        #maintainers = with maintainers; [ dtzWill ];
        platforms = platforms.all;
        # Not sure what version is required but 1.29 works and 1.27 doesn't
        /*
        broken =
          let
            rversion = rustPlatform.rust.rustc.version;
            oldrust = versionOlder rversion "1.29";
            maybeWarn = if oldrust then (x: warn "Rust version ${rversion} is too old for xi-editor, needs 1.29. Marking as broken accordingly." x) else id; # id = identity?
          in maybeWarn oldrust;
        */
      };
    };
    wrapXiFrontendHook = callPackage ./wrapper.nix { };

    #gxi = callPackage ./gxi { };
    #kod = callPackage ./kod { };
    xi-gtk = callPackage ./xi-gtk { };
    #xi-term = callPackage ./xi-term { };
  };
in self
