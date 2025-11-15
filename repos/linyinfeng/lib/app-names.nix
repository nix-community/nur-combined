{ lib }:

let
  extractPname = n: lib.lists.last (lib.strings.split "/" n);
  trivial =
    p:
    let
      pname = extractPname p;
    in
    {
      "${p}" = {
        "${p}" = pname;
      };
    };
  empty = p: { "${p}" = { }; };
  merge = lib.fold lib.recursiveUpdate { };
  appNamesDict = merge [
    # keep-sorted start block=yes
    (empty "canokey-udev-rules")
    (empty "fishPlugins/bang-bang")
    (empty "fishPlugins/git")
    (empty "fishPlugins/replay")
    (empty "libva-v4l2")
    (empty "niri-taskbar")
    (empty "rimePackages/librime")
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
    (empty "rimePackages/rimeDataBuildHook")
    (empty "yacd")
    (trivial "activate-dpt")
    (trivial "aws-s3-reverse-proxy")
    (trivial "aws-sigv4-proxy")
    (trivial "baibot")
    (trivial "cf-terraforming")
    (trivial "cowrie")
    (trivial "devPackages/nvfetcher-self")
    (trivial "devPackages/update")
    (trivial "dot-tar")
    (trivial "emacsPackages/pyim-greatdict")
    (trivial "lpac")
    (trivial "matrix-qq")
    (trivial "matrix-wechat")
    (trivial "moe-koe-music")
    (trivial "mstickereditor")
    (trivial "nvfetcher-changes")
    (trivial "nvfetcher-changes-commit")
    (trivial "ssl-handshake")
    (trivial "telegram-send")
    (trivial "tg-send")
    (trivial "trojan")
    (trivial "vlmcsd")
    (trivial "zeronsd")
    {
      "dpt-rp1-py" = {
        "dpt-rp1-py" = "dptrp1";
      };
    }
    {
      "easylpac" = {
        "EasyLPAC" = "EasyLPAC";
      };
    }
    {
      "ly2video" = {
        "ly2video" = "ly2video";
        "midi-rubato" = "midi-rubato";
        "xsc2beatmap" = "xsc2beatmap";
      };
    }
    {
      "matrix-media-repo" = {
        "matrix-media-repo" = "media_repo";
        "matrix-media-repo-gdpr-export" = "gdpr_export";
        "matrix-media-repo-gdpr-import" = "gdpr_import";
        "matrix-media-repo-import-synapse" = "import_synapse";
        "matrix-media-repo-s3-consistency-check" = "s3_consistency_check";
      };
    }
    {
      "minio-latest" = {
        "minio" = "minio";
      };
    }
    {
      "rcon-cli" = {
        "gorcon" = "gorcon";
      };
    }
    {
      "rlt" = {
        "localtunnel" = "localtunnel";
      };
    }
    # keep-sorted end
  ];
in
p: appNamesDict.${p}
