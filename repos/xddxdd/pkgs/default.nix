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
# - "legacy": from legacyPackages
mode:
{
  pkgs ? import <nixpkgs> { },
  ...
}:
let
  inherit (pkgs.callPackage ../helpers/group.nix { inherit mode; })
    createCallPackage
    createCallGroup
    ifNotCI
    mergePkgs
    ;

  callPackage = createCallPackage self;
  callGroup = p: mergePkgs (createCallGroup self callPackage p);

  self = {
    # Binary cache information
    _meta = callGroup ./_meta;

    # Package groups
    asteriskDigiumCodecs = callGroup ./asterisk-digium-codecs;
    lantianCustomized = callGroup ./lantian-customized;
    lantianLinuxXanmod = callGroup ./lantian-linux-xanmod;
    lantianLinuxXanmodPackages = ifNotCI (callGroup ./lantian-linux-xanmod/packages.nix);
    lantianPersonal = ifNotCI (callGroup ./lantian-personal);
    nvidia-grid = ifNotCI (callGroup ./nvidia-grid);
    openj9-ibm-semeru = ifNotCI (callGroup ./openj9-ibm-semeru);
    openjdk-adoptium = ifNotCI (callGroup ./openjdk-adoptium);
    plangothic-fonts = callGroup ./plangothic-fonts;
    th-fonts = callGroup ./th-fonts;

    # Kernel modules
    acpi-ec = callPackage ./kernel-modules/acpi-ec { };
    ast = callPackage ./kernel-modules/ast { };
    cryptodev-unstable = callPackage ./kernel-modules/cryptodev-unstable { };
    dpdk-kmod = callPackage ./kernel-modules/dpdk-kmod { };
    i915-sriov = callPackage ./kernel-modules/i915-sriov { };
    nft-fullcone = callPackage ./kernel-modules/nft-fullcone { };
    nullfsvfs = callPackage ./kernel-modules/nullfsvfs { };
    ovpn-dco = callPackage ./kernel-modules/ovpn-dco { };
    r8125 = callPackage ./kernel-modules/r8125 { };
    r8168 = callPackage ./kernel-modules/r8168 { };

    # Other packages
    amule-dlp = callPackage ./uncategorized/amule-dlp { };
    asterisk-g72x = callPackage ./uncategorized/asterisk-g72x { };
    axiom-syslog-proxy = callPackage ./uncategorized/axiom-syslog-proxy { };
    baidunetdisk = callPackage ./uncategorized/baidunetdisk { };
    baidupcs-go = callPackage ./uncategorized/baidupcs-go { };
    bepasty = callPackage ./uncategorized/bepasty { };
    bilibili = callPackage ./uncategorized/bilibili { };
    bird-lg-go = callPackage ./uncategorized/bird-lg-go { };
    bird-lgproxy-go = callPackage ./uncategorized/bird-lgproxy-go { };
    boringssl-oqs = callPackage ./uncategorized/boringssl-oqs { };
    browser360 = callPackage ./uncategorized/browser360 { };
    calibre-cops = callPackage ./uncategorized/calibre-cops { };
    chmlib-utils = callPackage ./uncategorized/chmlib-utils { };
    click-loglevel = callPackage ./uncategorized/click-loglevel { };
    cloudpan189-go = callPackage ./uncategorized/cloudpan189-go { };
    cockpy = callPackage ./uncategorized/cockpy { };
    decluttarr = callPackage ./uncategorized/decluttarr { };
    deepspeech-gpu = ifNotCI (callPackage ./uncategorized/deepspeech-gpu { });
    deepspeech-wrappers = ifNotCI (callPackage ./uncategorized/deepspeech-gpu/wrappers.nix { });
    dingtalk = callPackage ./uncategorized/dingtalk { };
    dn42-pingfinder = callPackage ./uncategorized/dn42-pingfinder { };
    douban-openapi-server = callPackage ./uncategorized/douban-openapi-server { };
    drone-file-secret = callPackage ./uncategorized/drone-file-secret { };
    drone-vault = callPackage ./uncategorized/drone-vault { };
    electron_11 = callPackage ./uncategorized/electron_11 { };
    etherguard = callPackage ./uncategorized/etherguard { };
    fastapi-dls = callPackage ./uncategorized/fastapi-dls { };
    fcitx5-breeze = callPackage ./uncategorized/fcitx5-breeze { };
    flasgger = callPackage ./uncategorized/flasgger { };
    ftp-proxy = callPackage ./uncategorized/ftp-proxy { };
    genshin-checkin-helper = callPackage ./uncategorized/genshin-checkin-helper { };
    genshinhelper2 = callPackage ./uncategorized/genshinhelper2 { };
    glauth = callPackage ./uncategorized/glauth { };
    google-earth-pro = callPackage ./uncategorized/google-earth-pro { };
    gopherus = callPackage ./uncategorized/gopherus { };
    grasscutter = callPackage ./uncategorized/grasscutter { };
    hath = callPackage ./uncategorized/hath { };
    helium-gateway-rs = callPackage ./uncategorized/helium-gateway-rs { };
    hesuvi-hrir = callPackage ./uncategorized/hesuvi-hrir { };
    hi3-ii-martian-font = callPackage ./uncategorized/hi3-ii-martian-font { };
    hoyo-glyphs = callPackage ./uncategorized/hoyo-glyphs { };
    imewlconverter = callPackage ./uncategorized/imewlconverter { };
    inter-knot = callPackage ./uncategorized/inter-knot { };
    jproxy = callPackage ./uncategorized/jproxy { };
    kaixinsong-fonts = callPackage ./uncategorized/kaixinsong-fonts { };
    kata-image = callPackage ./uncategorized/kata-image { };
    kata-runtime = callPackage ./uncategorized/kata-runtime { };
    kikoplay = callPackage ./uncategorized/kikoplay { };
    konnect = callPackage ./uncategorized/konnect { };
    ldap-auth-proxy = callPackage ./uncategorized/ldap-auth-proxy { };
    libnftnl-fullcone = callPackage ./uncategorized/libnftnl-fullcone { };
    liboqs = callPackage ./uncategorized/liboqs { };
    liboqs-unstable = callPackage ./uncategorized/liboqs/unstable.nix { };
    lyrica = callPackage ./uncategorized/lyrica { };
    lyrica-plasmoid = callPackage ./uncategorized/lyrica-plasmoid { };
    magiskboot = callPackage ./uncategorized/magiskboot { };
    mtkclient = callPackage ./uncategorized/mtkclient { };
    ncmdump-rs = callPackage ./uncategorized/ncmdump-rs { };
    netboot-xyz = callPackage ./uncategorized/netboot-xyz { };
    netease-cloud-music = callPackage ./uncategorized/netease-cloud-music { };
    netns-exec = callPackage ./uncategorized/netns-exec { };
    nftables-fullcone = callPackage ./uncategorized/nftables-fullcone { };
    noise-suppression-for-voice = callPackage ./uncategorized/noise-suppression-for-voice { };
    nullfs = callPackage ./uncategorized/nullfs { };
    nvlax = callPackage ./uncategorized/nvlax { };
    nvlax-530 = callPackage ./uncategorized/nvlax/nvidia-530.nix { };
    oci-arm-host-capacity = callPackage ./uncategorized/oci-arm-host-capacity { };
    onepush = callPackage ./uncategorized/onepush { };
    openssl-oqs-provider = callPackage ./uncategorized/openssl-oqs-provider { };
    openvswitch-dpdk = callPackage ./uncategorized/openvswitch-dpdk { };
    osdlyrics = callPackage ./uncategorized/osdlyrics { };
    palworld-exporter = callPackage ./uncategorized/palworld-exporter { };
    palworld-worldoptions = callPackage ./uncategorized/palworld-worldoptions { };
    payload-dumper-go = callPackage ./uncategorized/payload-dumper-go { };
    peerbanhelper = callPackage ./uncategorized/peerbanhelper { };
    phpmyadmin = callPackage ./uncategorized/phpmyadmin { };
    phppgadmin = callPackage ./uncategorized/phppgadmin { };
    plasma-panel-transparency-toggle = callPackage ./uncategorized/plasma-panel-transparency-toggle { };
    plasma-smart-video-wallpaper-reborn =
      callPackage ./uncategorized/plasma-smart-video-wallpaper-reborn
        { };
    pocl = callPackage ./uncategorized/pocl { };
    procps4 = callPackage ./uncategorized/procps4 { };
    pterodactyl-wings = callPackage ./uncategorized/pterodactyl-wings { };
    py-rcon = callPackage ./uncategorized/py-rcon { };
    qbittorrent-enhanced-edition = callPackage ./uncategorized/qbittorrent-enhanced-edition { };
    qbittorrent-enhanced-edition-nox =
      callPackage ./uncategorized/qbittorrent-enhanced-edition/nox.nix
        { };
    libqcef = callPackage ./uncategorized/libqcef { };
    qemu-user-static = callPackage ./uncategorized/qemu-user-static { };
    qhttpengine = callPackage ./uncategorized/qhttpengine { };
    qq = callPackage ./uncategorized/qq { };
    qqmusic = callPackage ./uncategorized/qqmusic { };
    rime-aurora-pinyin = callPackage ./uncategorized/rime-aurora-pinyin { };
    rime-custom-pinyin-dictionary = callPackage ./uncategorized/rime-custom-pinyin-dictionary { };
    rime-dict = callPackage ./uncategorized/rime-dict { };
    rime-ice = callPackage ./uncategorized/rime-ice { };
    rime-moegirl = callPackage ./uncategorized/rime-moegirl { };
    rime-zhwiki = callPackage ./uncategorized/rime-zhwiki { };
    route-chain = callPackage ./uncategorized/route-chain { };
    runpod-python = callPackage ./uncategorized/runpod-python { };
    runpodctl = callPackage ./uncategorized/runpodctl { };
    sam-toki-mouse-cursors = callPackage ./uncategorized/sam-toki-mouse-cursors { };
    sgx-software-enable = callPackage ./uncategorized/sgx-software-enable { };
    smartrent_py = callPackage ./uncategorized/smartrent_py { };
    smfc = callPackage ./uncategorized/smfc { };
    soggy = callPackage ./uncategorized/soggy { };
    space-cadet-pinball-full-tilt = callPackage ./uncategorized/space-cadet-pinball-full-tilt { };
    svp = callPackage ./uncategorized/svp { };
    svp-mpv = callPackage ./uncategorized/svp/mpv.nix { };
    sx1302-hal = callPackage ./uncategorized/sx1302-hal { };
    suwayomi-server = callPackage ./uncategorized/suwayomi-server { };
    tqdm-loggable = callPackage ./uncategorized/tqdm-loggable { };
    uesave = callPackage ./uncategorized/uesave { };
    uesave-0_3_0 = callPackage ./uncategorized/uesave/0_3_0.nix { };
    uksmd = callPackage ./uncategorized/uksmd { };
    vbmeta-disable-verification = callPackage ./uncategorized/vbmeta-disable-verification { };
    vgpu-unlock-rs = callPackage ./uncategorized/vgpu-unlock-rs { };
    vpp = callPackage ./uncategorized/vpp { };
    wechat-uos = callPackage ./uncategorized/wechat-uos { };
    wechat-uos-without-sandbox = callPackage ./uncategorized/wechat-uos {
      enableSandbox = false;
    };

    # Deprecated alias
    wechat-uos-bin = self.wechat-uos;

    wine-wechat = callPackage ./uncategorized/wine-wechat { };
    wine-wechat-x86 = callPackage ./uncategorized/wine-wechat-x86 { };
    xstatic-asciinema-player = callPackage ./uncategorized/xstatic-asciinema-player { };
    xstatic-font-awesome = callPackage ./uncategorized/xstatic-font-awesome { };
  };
in
self
