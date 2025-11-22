{
  lib,
  newScope,
  selfLib,
  pkgs,
}:

lib.makeScope newScope (
  self:
  let
    inherit (self) callPackage;
  in
  {
    sources = callPackage ./_sources/generated.nix { };
    devPackages = lib.recurseIntoAttrs (
      callPackage ./dev-packages {
        selfPackages = self;
        inherit selfLib;
      }
    );

    # keep-sorted start block=yes
    activate-dpt = callPackage ./activate-dpt { };
    aws-s3-reverse-proxy = callPackage ./aws-s3-reverse-proxy { };
    aws-sigv4-proxy = callPackage ./aws-sigv4-proxy { };
    baibot = callPackage ./baibot { };
    canokey-udev-rules = callPackage ./canokey-udev-rules { };
    cf-terraforming = callPackage ./cf-terraforming { };
    dot-tar = callPackage ./dot-tar { };
    dpt-rp1-py = callPackage ./dpt-rp1-py { };
    easylpac = callPackage ./easylpac { };
    emacsPackages = lib.recurseIntoAttrs (
      callPackage ./emacs-packages { emacsPackagesToplevel = pkgs.emacs.pkgs; }
    );
    fishPlugins = lib.recurseIntoAttrs (
      callPackage ./fish-plugins { fishPluginsToplevel = pkgs.fishPlugins; }
    );
    libva-v4l2 = callPackage ./libva-v4l2 { };
    lpac = callPackage ./lpac { };
    ly2video = callPackage ./ly2video { };
    matrix-media-repo = callPackage ./matrix-media-repo { };
    matrix-qq = callPackage ./matrix-qq { };
    matrix-wechat = callPackage ./matrix-wechat { };
    minio-latest = callPackage ./minio-latest { };
    moe-koe-music = callPackage ./moe-koe-music { };
    mstickereditor = callPackage ./mstickereditor { };
    niri-taskbar = callPackage ./niri-taskbar { };
    nvfetcher-changes = callPackage ./nvfetcher-changes { };
    nvfetcher-changes-commit = callPackage ./nvfetcher-changes-commit { };
    plangothic = callPackage ./plangothic { };
    rcon-cli = callPackage ./rcon-cli { };
    rimePackages = lib.recurseIntoAttrs (self.rimePackagesFor pkgs.librime);
    rimePackagesFor = librime: callPackage ./rime-packages { inherit librime; };
    rlt = callPackage ./rlt { };
    ssl-handshake = callPackage ./ssl-handshake { };
    telegram-send = callPackage ./telegram-send { };
    tg-send = callPackage ./tg-send { };
    trojan = callPackage ./trojan { };
    vlmcsd = callPackage ./vlmcsd { };
    yacd = callPackage ./yacd { };
    zeronsd = callPackage ./zeronsd { };
    # keep-sorted end
  }
)
