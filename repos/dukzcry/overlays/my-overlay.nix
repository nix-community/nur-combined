{ pkgs, config ? null }:

self: super: with super.lib;
rec {
  dtrx = super.dtrx.override {
    unzipSupport = true;
    unrarSupport = true;
  };
  # https://github.com/curl/curl/issues/7621
  curlftpfs = super.curlftpfs.override {
    curl = super.curl.overrideAttrs (oldAttrs: rec {
      pname = "curl";
      version = "7.77.0";
      src = super.fetchurl {
        urls = [
          "https://curl.haxx.se/download/${pname}-${version}.tar.bz2"
          "https://github.com/curl/curl/releases/download/${super.lib.replaceStrings ["."] ["_"] pname}-${version}/${pname}-${version}.tar.bz2"
        ];
        sha256 = "1spqbn2wyfh2dfsz2p60ap4194vnvf7rqfy4ky2r69dqij32h33c";
      };
      patches = [];
      doCheck = false;
    });
  };
  lmms = super.lmms.overrideAttrs (oldAttrs: optionalAttrs (config.services.jack.enable or false) {
    cmakeFlags = oldAttrs.cmakeFlags ++ [ "-DWANT_WEAKJACK=OFF" ];
  });
  qutebrowser = super.qutebrowser.overrideAttrs (oldAttrs: {
    postFixup = ''
      ${oldAttrs.postFixup}
      wrapProgram $out/bin/qutebrowser \
        --prefix PATH : "${super.lib.makeBinPath [ super.mpv ]}"
    '';
  });
  evolution = super.symlinkJoin {
    name = "evolution-without-background-processes";
    paths = with super; [
      (writeShellScriptBin "evolution" ''
        ${super.evolution}/bin/evolution "$@"
        ${super.evolution}/bin/evolution --force-shutdown
      '')
      super.evolution
    ];
  };
  ddccontrol = super.ddccontrol.overrideAttrs (oldAttrs: {
    prePatch = ''
      ${oldAttrs.prePatch}
      substituteInPlace src/gddccontrol/notebook.c \
        --replace "if (mon->fallback)" "if (0)"
    '';
  });
} // optionalAttrs (config.hardware.wifi.enable or false) {
  inherit (pkgs.nur.repos.dukzcry) wireless-regdb;
  crda = super.crda.overrideAttrs (oldAttrs: rec {
    makeFlags = oldAttrs.makeFlags ++ [
      "PUBKEY_DIR=${pkgs.nur.repos.dukzcry.wireless-regdb}/lib/crda/pubkeys"
    ];
  });
}
