# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage
# mode:
# - null: Default mode
# - "ci": from Garnix CI
# - "nur": from NUR bot
mode:
{
  pkgs ? import <nixpkgs> { },
  inputs ? null,
  ...
}:
let
  inherit (pkgs) lib;

  ifNotCI = p: if mode == "ci" then null else p;

  ifNotNUR = p: if mode == "nur" then null else p;

  mkScope =
    f:
    builtins.removeAttrs
      (lib.makeScope pkgs.newScope (
        self:
        let
          pkg = self.newScope {
            inherit mkScope;
            sources = self.callPackage ../_sources/generated.nix { };
          };
        in
        f self pkg
      ))
      [
        "newScope"
        "callPackage"
        "overrideScope"
        "overrideScope'"
        "packages"
      ];
in
mkScope (
  self: pkg:
  let
    # Wrapper will greatly increase NUR evaluation time. Disable on NUR to stay within 15s time limit.
    mergePkgs = self.callPackage ../helpers/merge-pkgs.nix { enableWrapper = mode != "nur"; };
  in
  {
    # Binary cache information
    _meta = mergePkgs {
      url = "https://xddxdd.cachix.org";
      publicKey = "xddxdd.cachix.org-1:ay1HJyNDYmlSwj5NXQG065C8LfoqqKaTNCyzeixGjf8=";

      howto = pkg ./_meta/howto { };
      readme = pkg ./_meta/readme { };
    };

    # Package groups
    asteriskDigiumCodecs = mergePkgs (pkg ./asterisk-digium-codecs { inherit mergePkgs; });

    lantianCustomized = mergePkgs {
      # Packages with significant customization by Lan Tian
      asterisk = pkg ./lantian-customized/asterisk { };
      attic-telnyx-compatible = ifNotNUR (pkg ./lantian-customized/attic-telnyx-compatible { });
      coredns = pkg ./lantian-customized/coredns { };
      firefox-icon-mikozilla-fireyae = pkg ./lantian-customized/firefox-icon-mikozilla-fireyae { };
      librime-with-plugins = pkg ./lantian-customized/librime-with-plugins { };
      nbfc-linux = pkg ./lantian-customized/nbfc-linux { };
      nginx = pkg ./lantian-customized/nginx { };
      transmission-with-webui = pkg ./lantian-customized/transmission-with-webui { };
    };

    lantianLinuxXanmod = ifNotCI (mergePkgs (pkg ./lantian-linux-xanmod { }));
    lantianLinuxXanmodPackages = ifNotCI (mergePkgs (pkg ./lantian-linux-xanmod/packages.nix { }));

    lantianPersonal = ifNotCI (mergePkgs {
      # Personal packages with no intention to be used by others
      libltnginx = pkg ./lantian-personal/libltnginx { };
    });

    nvidia-grid = ifNotCI (mergePkgs (pkg ./nvidia-grid { inherit mergePkgs; }));
    openj9-ibm-semeru = ifNotCI (mergePkgs (pkg ./openj9-ibm-semeru { }));
    openjdk-adoptium = ifNotCI (mergePkgs (pkg ./openjdk-adoptium { }));
    plangothic-fonts = mergePkgs (pkg ./plangothic-fonts { });
    th-fonts = mergePkgs (pkg ./th-fonts { });

    # Kernel modules
    kernel = pkgs.linux;
    acpi-ec = pkg ./kernel-modules/acpi-ec { };
    cryptodev-unstable = pkg ./kernel-modules/cryptodev-unstable { };
    dpdk-kmod = pkg ./kernel-modules/dpdk-kmod { };
    i915-sriov = pkg ./kernel-modules/i915-sriov { };
    nft-fullcone = pkg ./kernel-modules/nft-fullcone { };
    nullfsvfs = pkg ./kernel-modules/nullfsvfs { };
    ovpn-dco = pkg ./kernel-modules/ovpn-dco { };
    r8125 = pkg ./kernel-modules/r8125 { };
    r8168 = pkg ./kernel-modules/r8168 { };

    # Other packages
    amule-dlp = pkg ./uncategorized/amule-dlp { };
    asterisk-g72x = pkg ./uncategorized/asterisk-g72x { };
    baidunetdisk = pkg ./uncategorized/baidunetdisk { };
    baidupcs-go = pkg ./uncategorized/baidupcs-go { };
    bepasty = pkg ./uncategorized/bepasty { };
    bilibili = pkg ./uncategorized/bilibili { };
    bird-lg-go = pkg ./uncategorized/bird-lg-go { };
    bird-lgproxy-go = pkg ./uncategorized/bird-lgproxy-go { };
    boringssl-oqs = pkg ./uncategorized/boringssl-oqs { };
    calibre-cops = pkg ./uncategorized/calibre-cops { };
    chmlib-utils = pkg ./uncategorized/chmlib-utils { };
    click-loglevel = pkg ./uncategorized/click-loglevel { };
    cloudpan189-go = pkg ./uncategorized/cloudpan189-go { };
    cockpy = pkg ./uncategorized/cockpy { };
    decluttarr = pkg ./uncategorized/decluttarr { };
    deepspeech-gpu = ifNotCI (pkg ./uncategorized/deepspeech-gpu { });
    deepspeech-wrappers = ifNotCI (pkg ./uncategorized/deepspeech-gpu/wrappers.nix { });
    dingtalk = pkg ./uncategorized/dingtalk { };
    dn42-pingfinder = pkg ./uncategorized/dn42-pingfinder { };
    douban-openapi-server = pkg ./uncategorized/douban-openapi-server { };
    drone-file-secret = pkg ./uncategorized/drone-file-secret { };
    drone-vault = pkg ./uncategorized/drone-vault { };
    electron_11 = pkg ./uncategorized/electron_11 { };
    etherguard = pkg ./uncategorized/etherguard { };
    fastapi-dls = pkg ./uncategorized/fastapi-dls { };
    fcitx5-breeze = pkg ./uncategorized/fcitx5-breeze { };
    flaresolverr = pkg ./uncategorized/flaresolverr { };
    flasgger = pkg ./uncategorized/flasgger { };
    ftp-proxy = pkg ./uncategorized/ftp-proxy { };
    genshin-checkin-helper = pkg ./uncategorized/genshin-checkin-helper { };
    genshinhelper2 = pkg ./uncategorized/genshinhelper2 { };
    glauth = pkg ./uncategorized/glauth { };
    google-earth-pro = pkg ./uncategorized/google-earth-pro { };
    gopherus = pkg ./uncategorized/gopherus { };
    grasscutter = pkg ./uncategorized/grasscutter { };
    hath = pkg ./uncategorized/hath { };
    hesuvi-hrir = pkg ./uncategorized/hesuvi-hrir { };
    hoyo-glyphs = pkg ./uncategorized/hoyo-glyphs { };
    jproxy = pkg ./uncategorized/jproxy { };
    kaixinsong-fonts = pkg ./uncategorized/kaixinsong-fonts { };
    kata-image = pkg ./uncategorized/kata-image { };
    kata-runtime = pkg ./uncategorized/kata-runtime { };
    konnect = pkg ./uncategorized/konnect { };
    ldap-auth-proxy = pkg ./uncategorized/ldap-auth-proxy { };
    libnftnl-fullcone = pkg ./uncategorized/libnftnl-fullcone { };
    liboqs = pkg ./uncategorized/liboqs { };
    netboot-xyz = pkg ./uncategorized/netboot-xyz { };
    netease-cloud-music = pkg ./uncategorized/netease-cloud-music { };
    netns-exec = pkg ./uncategorized/netns-exec { };
    nftables-fullcone = pkg ./uncategorized/nftables-fullcone { };
    noise-suppression-for-voice = pkg ./uncategorized/noise-suppression-for-voice { };
    nullfs = pkg ./uncategorized/nullfs { };
    nvlax = pkg ./uncategorized/nvlax { };
    nvlax-530 = pkg ./uncategorized/nvlax/nvidia-530.nix { };
    oci-arm-host-capacity = pkg ./uncategorized/oci-arm-host-capacity { };
    onepush = pkg ./uncategorized/onepush { };
    openssl-oqs = pkg ./uncategorized/openssl-oqs { cryptodev = pkgs.linuxPackages.cryptodev; };
    openssl-oqs-provider = pkg ./uncategorized/openssl-oqs-provider { };
    osdlyrics = pkg ./uncategorized/osdlyrics { };
    palworld-exporter = pkg ./uncategorized/palworld-exporter { };
    palworld-worldoptions = pkg ./uncategorized/palworld-worldoptions { };
    payload-dumper-go = pkg ./uncategorized/payload-dumper-go { };
    peerbanhelper = pkg ./uncategorized/peerbanhelper { };
    phpmyadmin = pkg ./uncategorized/phpmyadmin { };
    phppgadmin = pkg ./uncategorized/phppgadmin { };
    plasma-desktop-lyrics = pkg ./uncategorized/plasma-desktop-lyrics { };
    plasma-desktop-lyrics-plasmoid = pkg ./uncategorized/plasma-desktop-lyrics-plasmoid { };
    plasma-panel-transparency-toggle = pkg ./uncategorized/plasma-panel-transparency-toggle { };
    procps4 = pkg ./uncategorized/procps4 { };
    pterodactyl-wings = pkg ./uncategorized/pterodactyl-wings { };
    py-rcon = pkg ./uncategorized/py-rcon { };
    qbittorrent-enhanced-edition = pkg ./uncategorized/qbittorrent-enhanced-edition { };
    qbittorrent-enhanced-edition-nox = pkg ./uncategorized/qbittorrent-enhanced-edition/nox.nix { };
    libqcef = pkg ./uncategorized/libqcef { };
    qemu-user-static = pkg ./uncategorized/qemu-user-static { };
    qq = pkg ./uncategorized/qq { };
    qqmusic = pkg ./uncategorized/qqmusic { };
    rime-aurora-pinyin = pkg ./uncategorized/rime-aurora-pinyin { };
    rime-dict = pkg ./uncategorized/rime-dict { };
    rime-ice = pkg ./uncategorized/rime-ice { };
    rime-moegirl = pkg ./uncategorized/rime-moegirl { };
    rime-zhwiki = pkg ./uncategorized/rime-zhwiki { };
    route-chain = pkg ./uncategorized/route-chain { };
    sam-toki-mouse-cursors = pkg ./uncategorized/sam-toki-mouse-cursors { };
    smartrent_py = pkg ./uncategorized/smartrent_py { };
    sgx-software-enable = pkg ./uncategorized/sgx-software-enable { };
    soggy = pkg ./uncategorized/soggy { };
    space-cadet-pinball-full-tilt = pkg ./uncategorized/space-cadet-pinball-full-tilt { };
    svp = pkg ./uncategorized/svp { };
    svp-mpv = pkg ./uncategorized/svp/mpv.nix { };
    tachidesk-server = pkg ./uncategorized/tachidesk-server { };
    uesave = pkg ./uncategorized/uesave { };
    uksmd = pkg ./uncategorized/uksmd { };
    undetected-chromedriver = pkg ./uncategorized/undetected-chromedriver { };
    undetected-chromedriver-bin = pkg ./uncategorized/undetected-chromedriver-bin { };
    vivado-2022_2 = ifNotCI (pkg ./uncategorized/vivado-2022_2 { });
    vpp = pkg ./uncategorized/vpp { };
    vs-rife = pkg ./uncategorized/vs-rife { };
    wechat-uos = pkg ./uncategorized/wechat-uos { };
    wechat-uos-without-sandbox = pkg ./uncategorized/wechat-uos { enableSandbox = false; };

    # Deprecated alias
    wechat-uos-bin = self.wechat-uos;

    win2xcur = pkg ./uncategorized/win2xcur { };
    wine-wechat = lib.makeOverridable pkg ./uncategorized/wine-wechat { };
    wine-wechat-x86 = lib.makeOverridable pkg ./uncategorized/wine-wechat-x86 { };
    xstatic-asciinema-player = pkg ./uncategorized/xstatic-asciinema-player { };
    xstatic-font-awesome = pkg ./uncategorized/xstatic-font-awesome { };
  }
)
