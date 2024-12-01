{ pkgs, config ? null }:

self: super: with super.lib;
rec {
  dtrx = super.dtrx.override {
    unzipSupport = true;
    unrarSupport = true;
  };
  qmmp = super.qmmp.overrideAttrs (oldAttrs: rec {
    buildInputs = oldAttrs.buildInputs ++ (with super; [ libxmp libsidplayfp ]);
  });
  # https://github.com/swaywm/sway/issues/3111#issuecomment-508958733
  sway-unwrapped = super.sway-unwrapped.overrideAttrs (oldAttrs: rec {
    postUnpack = ''
      substituteInPlace source/sway/commands/bind.c \
        --replace "if ((binding->flags & BINDING_CODE) == 0) {" "if (false) {"
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
  });
} // optionalAttrs (config.hardware.regdomain.enable or false) {
  inherit (pkgs.nur.repos.dukzcry) wireless-regdb;
  crda = super.crda.overrideAttrs (oldAttrs: rec {
    makeFlags = oldAttrs.makeFlags ++ [
      "PUBKEY_DIR=${pkgs.nur.repos.dukzcry.wireless-regdb}/lib/crda/pubkeys"
    ];
  });
}
