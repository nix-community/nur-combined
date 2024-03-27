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

    activate-dpt = callPackage ./activate-dpt { };
    aws-s3-reverse-proxy = callPackage ./aws-s3-reverse-proxy { };
    aws-sigv4-proxy = callPackage ./aws-sigv4-proxy { };
    canokey-udev-rules = callPackage ./canokey-udev-rules { };
    cf-terraforming = callPackage ./cf-terraforming { };
    dot-tar = callPackage ./dot-tar { };
    dpt-rp1-py = callPackage ./dpt-rp1-py { };
    easylpac = callPackage ./easylpac { };
    emacsPackages = lib.recurseIntoAttrs (
      callPackage ./emacs-packages { emacsPackagesToplevel = pkgs.emacsPackages; }
    );
    fishPlugins = lib.recurseIntoAttrs (
      callPackage ./fish-plugins { fishPluginsToplevel = pkgs.fishPlugins; }
    );
    icalingua-plus-plus = callPackage ./icalingua-plus-plus { };
    lpac = callPackage ./lpac { };
    matrix-chatgpt-bot = callPackage ./matrix-chatgpt-bot {
      matrix-sdk-crypto-nodejs =
        if pkgs.matrix-sdk-crypto-nodejs.version == "0.1.0-beta.3" then
          pkgs.matrix-sdk-crypto-nodejs
        else
          pkgs.matrix-sdk-crypto-nodejs-0_1_0-beta_3;
    };
    matrix-media-repo = callPackage ./matrix-media-repo { };
    matrix-qq = callPackage ./matrix-qq { };
    matrix-wechat = callPackage ./matrix-wechat { };
    minio-latest = callPackage ./minio-latest { };
    mstickereditor = callPackage ./mstickereditor { };
    nvfetcher-changes = callPackage ./nvfetcher-changes { };
    nvfetcher-changes-commit = callPackage ./nvfetcher-changes-commit { };
    rcon-cli = callPackage ./rcon-cli { };
    rimePackagesFor = librime: callPackage ./rime-packages { inherit librime; };
    rimePackages = lib.recurseIntoAttrs (self.rimePackagesFor pkgs.librime);
    ssl-handshake = callPackage ./ssl-handshake { };
    swayosd = callPackage ./swayosd { };
    synapse-s3-storage-provider = callPackage ./synapse-s3-storage-provider { };
    telegram-send = callPackage ./telegram-send { };
    tg-send = callPackage ./tg-send { };
    trojan = callPackage ./trojan { };
    vlmcsd = callPackage ./vlmcsd { };
    wemeet = callPackage ./wemeet { };
    yacd = callPackage ./yacd { };
    zeronsd = callPackage ./zeronsd { };
  }
)
