{ lib }:

let
  extractPname = n: lib.lists.last (lib.strings.split "/" n);
  trivial = p:
    let pname = extractPname p; in
    {
      "${p}" = {
        "${p}" = pname;
      };
    };
  empty = p: { "${p}" = { }; };
  merge = lib.fold lib.recursiveUpdate { };
  appNamesDict = merge [
    (trivial "activate-dpt")
    (trivial "aws-s3-reverse-proxy")
    (trivial "aws-sigv4-proxy")
    {
      "bird-babel-rtt" = {
        "bird-babel-rtt" = "bird";
        "birdc-babel-rtt" = "birdc";
        "birdcl-babel-rtt" = "birdcl";
      };
    }
    (empty "canokey-udev-rules")
    (trivial "cf-terraforming")
    { "clash-for-windows" = { "clash-for-windows" = "cfw"; }; }
    (trivial "clash-premium")
    (trivial "commit-notifier")
    (trivial "cowrie")
    (trivial "devPackages/nvfetcher-self")
    (trivial "devPackages/update")
    (trivial "dot-tar")
    { "dpt-rp1-py" = { "dpt-rp1-py" = "dptrp1"; }; }
    (trivial "emacsPackages/pyim-greatdict")
    (empty "fishPlugins/bang-bang")
    (empty "fishPlugins/git")
    (empty "fishPlugins/replay")
    (trivial "icalingua-plus-plus")
    (trivial "matrix-chatgpt-bot")
    {
      "matrix-media-repo" = {
        "matrix-media-repo" = "media_repo";
        "matrix-media-repo-gdpr-export" = "gdpr_export";
        "matrix-media-repo-gdpr-import" = "gdpr_import";
        "matrix-media-repo-import-synapse" = "import_synapse";
        "matrix-media-repo-s3-consistency-check" = "s3_consistency_check";
      };
    }
    (trivial "matrix-qq")
    (trivial "matrix-wechat")
    { "minio-latest" = { "minio" = "minio"; }; }
    (trivial "mstickereditor")
    (trivial "nvfetcher-changes")
    (trivial "nvfetcher-changes-commit")
    (empty "rimePackages/librime")
    (empty "rimePackages/rimeDataBuildHook")
    (empty "rimePackages/rime-bopomofo")
    (empty "rimePackages/rime-cangjie")
    (empty "rimePackages/rime-cantonese")
    (empty "rimePackages/rime-double-pinyin")
    (empty "rimePackages/rime-emoji")
    (empty "rimePackages/rime-essay")
    (empty "rimePackages/rime-ice")
    (empty "rimePackages/rime-loengfan")
    (empty "rimePackages/rime-luna-pinyin")
    (empty "rimePackages/rime-pinyin-simp")
    (empty "rimePackages/rime-prelude")
    (empty "rimePackages/rime-quick")
    (empty "rimePackages/rime-stroke")
    (empty "rimePackages/rime-terra-pinyin")
    (empty "rimePackages/rime-wubi")
    (empty "rimePackages/rime-wugniu")
    (trivial "swayosd")
    (trivial "telegram-send")
    (empty "synapse-s3-storage-provider")
    (trivial "tg-send")
    (trivial "trojan")
    (trivial "vlmcsd")
    {
      "wemeet" = {
        "wemeet" = "wemeetapp";
        "wemeet-force-x11" = "wemeetapp-force-x11";
      };
    }
    (empty "yacd")
    (trivial "zeronsd")
  ];
in
p: appNamesDict.${p}
