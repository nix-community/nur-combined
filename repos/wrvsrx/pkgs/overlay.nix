final: prev:
let
  inherit (final) callPackage;
  sources = callPackage ./_sources/generated.nix { };
  toplevelPackages = {
    # toplevel packages
    goauthing = callPackage ./goauthing { };
    autodiff = callPackage ./autodiff { source = sources.autodiff; };
    cyCodeBase = callPackage ./cyCodeBase { source = sources.cyCodeBase; };
    hougeo = callPackage ./hougeo { source = sources.hougeo; };
    happly = callPackage ./happly { source = sources.happly; };
    cnpy = callPackage ./cnpy { source = sources.cnpy; };
    amgcl = callPackage ./amgcl { source = sources.amgcl; };
    cuda-samples-common = callPackage ./cuda-samples-common { };
    structopt = callPackage ./structopt { source = sources.structopt; };
    utfcpp = callPackage ./utfcpp { source = sources.utfcpp; };
    seal_lake = callPackage ./seal_lake { source = sources.seal_lake; };
    sfun = callPackage ./sfun { source = sources.sfun; };
    cmdlime = callPackage ./cmdlime { source = sources.cmdlime; };
    vscode-markdown-languageserver = callPackage ./vscode-markdown-languageserver { };
    # I originally planned to package https://github.com/MetaCubeX/meta-rules-dat , but it only keeps the latest release and doesn't have reproducible URLs, so I used https://github.com/Loyalsoldier/v2ray-rules-dat instead, which has the same content.
    v2ray-rules-dat = callPackage ./v2ray-rules-dat {
      inherit (sources) v2ray-rules-dat-geoip v2ray-rules-dat-geosite;
    };

    # my packages
    giraffe-wallpaper = callPackage ./giraffe-wallpaper { source = sources.giraffe-wallpaper; };
    ptrace-time-hook = callPackage ./ptrace-time-hook { source = sources.ptrace-time-hook; };

    # override packages
    pam_ssh_agent_auth = callPackage ./pam_ssh_agent_auth { inherit (prev) pam_ssh_agent_auth; };
    xclip = callPackage ./xclip {
      inherit (prev) xclip;
      source = sources.xclip;
    };
    librime = callPackage ./librime { inherit (prev) librime; };
    fcitx5-rime = callPackage ./fcitx5-rime {
      inherit (prev) fcitx5-rime;
      inherit (final) librime;
    };
    niri = callPackage ./niri { inherit (prev) niri; };
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
  qt5-overlay = qfinal: qprev: {
    qt5ct = qprev.callPackage ./qt5ct {
      inherit (qprev)
        qt5ct
        kconfig
        kconfigwidgets
        kiconthemes
        ;
    };
  };
  kde-overlay = kfinal: kprev: {
    qt6ct = kprev.callPackage ./qt6ct {
      inherit (kprev)
        qt6ct
        kcolorscheme
        kconfig
        kiconthemes
        ;
    };
  };
  lib-overlay = import ./lib-overlay final prev;
  rimePackages = callPackage ./rime-packages {
    inherit sources;
    inherit (final) librime;
  };
  leanPackages = callPackage ./lean-packages {
    inherit sources;
  };
in
toplevelPackages
# nested packages
// {
  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [ python-overlay ];
  haskellPackages = prev.haskellPackages.extend haskell-overlay;
  vimPlugins = prev.vimPlugins.extend vim-plugins-overlay;
  libsForQt5 = prev.libsForQt5.overrideScope qt5-overlay;
  kdePackages = prev.kdePackages.overrideScope kde-overlay;
  lib = prev.lib.extend lib-overlay;
  inherit
    rimePackages
    leanPackages
    ;

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
    kdePackages._packageNames = builtins.attrNames (kde-overlay prev.kdePackages prev.kdePackages);
    libsForQt5._packageNames = builtins.attrNames (qt5-overlay prev.libsForQt5 prev.libsForQt5);
    leanPackages._packageNames = builtins.attrNames leanPackages;
  };
}
