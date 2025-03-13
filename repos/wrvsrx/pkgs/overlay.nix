final: prev:
let
  inherit (final) callPackage;
  sources = callPackage ./_sources/generated.nix { };
  mkNotoCJK =
    { source }:
    let
      ver = source.version;
      typeface = builtins.substring 0 (builtins.stringLength ver - 5) ver;
      version = builtins.substring (builtins.stringLength ver - 5) 5 ver;
      pkg = prev."noto-fonts-cjk-${prev.lib.strings.toLower typeface}";
    in
    pkg.overrideAttrs {
      inherit (source) src;
      inherit version;
      installPhase = ''
        install -m444 -Dt $out/share/fonts/opentype/noto-cjk ${typeface}/OTC/*.ttc
      '';
    };
  toplevelPackages = {
    # toplevel packages
    auth-thu = callPackage ./auth-thu { };
    autodiff = callPackage ./autodiff { source = sources.autodiff; };
    noto-fonts-cjk-sans-fix-weight = mkNotoCJK {
      source = sources.noto-fonts-cjk-sans-fix-weight;
    };
    noto-fonts-cjk-serif-fix-weight = mkNotoCJK {
      source = sources.noto-fonts-cjk-serif-fix-weight;
    };
    cyCodeBase = callPackage ./cyCodeBase { source = sources.cyCodeBase; };
    hougeo = callPackage ./hougeo { source = sources.hougeo; };
    happly = callPackage ./happly { source = sources.happly; };
    cnpy = callPackage ./cnpy { source = sources.cnpy; };
    amgcl = callPackage ./amgcl { source = sources.amgcl; };
    cuda-samples-common = callPackage ./cuda-samples-common { };
    structopt = callPackage ./structopt { source = sources.structopt; };
    utfcpp = callPackage ./utfcpp { source = sources.utfcpp; };
    seal_lake = callPackage ./seal_lake { source = sources.seal_lake; };
    sfun = callPackage ./sfun {
      source = sources.sfun;
    };
    cmdlime = callPackage ./cmdlime {
      source = sources.cmdlime;
    };
    yalantinglibs = callPackage ./yalantinglibs { source = sources.yalantinglibs; };
    baikal = callPackage ./baikal { };
    sillytavern = callPackage ./sillytavern { };
    vscode-markdown-languageserver = callPackage ./vscode-markdown-languageserver {
    };
    v2ray-rules-dat = callPackage ./v2ray-rules-dat {
      inherit (sources) v2ray-rules-dat-geoip v2ray-rules-dat-geosite;
    };
    wechat-uos-bwrapped = callPackage ./wechat-uos-bwrapped {
      inherit (prev) wechat-uos;
    };

    # my packages
    giraffe-wallpaper = callPackage ./giraffe-wallpaper {
      source = sources.giraffe-wallpaper;
    };

    # override packages
    pam_ssh_agent_auth = callPackage ./pam_ssh_agent_auth { inherit (prev) pam_ssh_agent_auth; };
    xclip = callPackage ./xclip {
      inherit (prev) xclip;
      source = sources.xclip;
    };
    lyra = callPackage ./lyra {
      inherit (prev) lyra;
      source = sources.lyra;
    };
    librime = callPackage ./librime { inherit (prev) librime; };
    fcitx5-rime = callPackage ./fcitx5-rime {
      inherit (prev) fcitx5-rime;
      inherit (final) librime;
    };
    p7zip = prev.p7zip.override { enableUnfree = true; };
    remmina = prev.remmina.override { withKf5Wallet = false; };
    qt5ct = prev.libsForQt5.callPackage ./qt5ct { };
    qt6ct = prev.kdePackages.callPackage ./qt6ct { };
    systemd' = callPackage ./systemd-patched { };
    meson' = callPackage ./meson-patched { };
  };
  python-overlay = import ./python-overlay { inherit sources; };
  haskell-overlay = import ./haskell-overlay {
    inherit sources;
    pkgs = prev;
  };
  vim-plugins-overlay = import ./vim-plugins-overlay {
    inherit sources callPackage;
    inherit (prev.vimUtils) buildVimPlugin;
  };
  lib-overlay = import ./lib-overlay final prev;
  rimePackages = callPackage ./rime-packages {
    sources = sources;
    inherit (final) librime;
  };
in
toplevelPackages
# nested packages
// {
  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [ python-overlay ];
  haskellPackages = prev.haskellPackages.extend haskell-overlay;
  vimPlugins = prev.vimPlugins.extend vim-plugins-overlay;
  lib = prev.lib.extend lib-overlay;
  inherit rimePackages;
  nur-wrvsrx._packageNames = {
    _packageNames = builtins.attrNames toplevelPackages;
    python3Packages._packageNames = builtins.attrNames (
      python-overlay prev.python3.pkgs prev.python3.pkgs
    );
    haskellPackages._packageNames = builtins.attrNames (
      haskell-overlay prev.haskellPackages prev.haskellPackages
    );
    vimPlugins._packageNames = builtins.attrNames (
      vim-plugins-overlay prev.vimUtils.vimPlugins prev.vimUtils.vimPlugins
    );
    rimePackages._packageNames = builtins.attrNames rimePackages;
  };
}
