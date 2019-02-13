{ lib, fetchFromGitHub, rustPlatform, newScope }:

let
  version = "2019-02-11";
  xi-editor-src = fetchFromGitHub {
    owner = "xi-editor";
    repo = "xi-editor";
    rev = "ed6d2109d0414fa665c433d19a1d58ef0fd80d2e";
    sha256 = "1ymfznk0pgvrg5bki71c6cx00w9pxka6gad9ykjyix4ii2nmcl3g";
  };
  callPackage = newScope self;
  self = {
    xi-core = rustPlatform.buildRustPackage {
      name = "xi-core-${version}";
      inherit version;

      src = xi-editor-src;

      sourceRoot = "source/rust";

      cargoPatches = [ ./0001-only-use-one-version-of-syntect.patch ];

      cargoSha256 = "1jy7jfkpmp1xg6jj8di8g6wvn12f9mrqf63qx09n2hgr23fxcbd5";

      postInstall = ''
        make -C syntect-plugin install XI_PLUGIN_DIR=$out/share/xi/plugins
        ln -vrs $out/share/xi/plugins/syntect $syntect
      '';

      outputs = [ "out" "syntect" ];

      meta = with lib; {
        description = "A modern editor with a backend written in Rust";
        homepage = https://github.com/xi-editor/xi-editor;
        license = licenses.asl20;
        maintainers = with maintainers; [ dtzWill ];
        platforms = platforms.all;
        # Not sure what version is required but 1.29 works and 1.27 doesn't
        broken =
          let
            rversion = rustPlatform.rust.rustc.version;
            oldrust = versionOlder rversion "1.29";
            maybeWarn = if oldrust then (x: warn "Rust version ${rversion} is too old for xi-editor, needs 1.29. Marking as broken accordingly." x) else id /*entity*/;
          in maybeWarn oldrust;
      };
    };
    wrapXiFrontendHook = callPackage ./wrapper.nix { };

    gxi = callPackage ./gxi { };
    kod = callPackage ./kod { };
    xi-gtk = callPackage ./xi-gtk { };
    xi-term = callPackage ./xi-term { };
  };
in self
