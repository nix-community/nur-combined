{ lib, fetchFromGitHub, rustPlatform, newScope }:

let
  version = "2018-10-24";
  xi-editor-src = fetchFromGitHub {
    owner = "xi-editor";
    repo = "xi-editor";
    rev = "54df4e99d7f1a1e89bac556fe6e94dd83c2b025b";
    sha256 = "00i75gw77k4vxl2nxp38qcdpsvskw9sg5vqrnvssim1ipmlgkfdh";
  };
  callPackage = newScope self;
  self = {
    xi-core = rustPlatform.buildRustPackage {
      name = "xi-core-${version}";
      inherit version;

      src = xi-editor-src;

      sourceRoot = "source/rust";

      cargoSha256 = "0mmzwzibc6rfn7y3jw7fim5xhilrbq5vbs7jkmihiq3n2zxvwaw8";

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
