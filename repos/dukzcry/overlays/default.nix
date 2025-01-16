{ pkgs, config ? null }:

self: super: with super.lib;
rec {
  dtrx = super.dtrx.override {
    unzipSupport = true;
    unrarSupport = true;
  };
  # todo: remove with next release
  qmmp = super.qmmp.overrideAttrs (oldAttrs: rec {
    buildInputs = oldAttrs.buildInputs ++ (with super; [ libxmp libsidplayfp ]);
  });
  # https://github.com/swaywm/sway/issues/3111#issuecomment-508958733
  sway-unwrapped = super.sway-unwrapped.overrideAttrs (oldAttrs: rec {
    postUnpack = ''
      substituteInPlace source/sway/commands/bind.c \
        --replace-fail "if ((binding->flags & BINDING_CODE) == 0) {" "if (false) {"
    '';
  });
  # https://github.com/NixOS/nixpkgs/issues/355277
  libsForQt5 = super.libsForQt5.overrideScope (qself: qsuper: {
    qtstyleplugin-kvantum = qsuper.qtstyleplugin-kvantum.overrideAttrs (oldAttrs: rec {
      version = "1.1.2";
      src = super.fetchFromGitHub {
        owner = "tsujan";
        repo = "Kvantum";
        rev = "V${version}";
        hash = "sha256-1aeXcN9DwPE8CoaxCqCNL9UEcRHJdaKxS7Ivjp3YNN8=";
      };
      nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ qsuper.kwindowsystem ];
    });
    plasma-workspace = qsuper.plasma-workspace.overrideAttrs (oldAttrs: rec {
      postFixup = ''
        ${oldAttrs.postFixup}
        substituteInPlace $out/share/sddm/themes/breeze/Main.qml \
          --replace-fail "sddm.suspend" "sddm.hibernate"
      '';
    });
  });
  # https://github.com/NixOS/nixpkgs/pull/299298#issuecomment-2508714160
  emulationstation-de = super.emulationstation-de.overrideAttrs (oldAttrs: rec {
    version = "3.0.2";
    src = super.fetchzip {
      url = "https://gitlab.com/es-de/emulationstation-de/-/archive/v${version}/emulationstation-de-v${version}.tar.gz";
      hash = "sha256:RGlXFybbXYx66Hpjp2N3ovK4T5VyS4w0DWRGNvbwugs=";
    };
    patches = [ ./002-add-nixpkgs-retroarch-cores-linux.patch ];
    installPhase = ''
      # Binary
      install -D ../es-de $out/bin/es-de
      # Resources
      mkdir -p $out/share/es-de/
      cp -r ../resources/ $out/share/es-de/resources/
    '';
  });
} // optionalAttrs (config.hardware.regdomain.enable or false) {
  inherit (pkgs.nur.repos.dukzcry) wireless-regdb;
  crda = super.crda.overrideAttrs (oldAttrs: rec {
    makeFlags = oldAttrs.makeFlags ++ [
      "PUBKEY_DIR=${pkgs.nur.repos.dukzcry.wireless-regdb}/lib/crda/pubkeys"
    ];
  });
}
