{ pkgs ? import <nixpkgs> {}
, localUsage ? false
, nixosVersion ? "master"
}:
let
  lib = pkgs.lib;
  python_with_openpyxl305 = with pkgs; python3.override {
    packageOverrides = with python3Packages; self: super: {
      openpyxl = openpyxl.overrideAttrs (old: {
        version = "3.0.5";
        src = fetchPypi {
          pname = "openpyxl";
          version = "3.0.5";
          sha256 = "06y7lbqnn0ga2x55az4hkqfs202fl6mkv3m5h0js2a01cnd1zq8q";
        };
      });
    };
  };
  kdeApplications = pkgs.libsForQt5.kdeApplications;
in
pkgs.lib.traceValFn (x:
 "Nixpkgs version : ${pkgs.lib.version},
  Nixos Version : ${nixosVersion},
  Local Usage : ${if localUsage then "true" else "false"}"
)
(lib.makeExtensible (self:
{
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions

  android-platform-tools = pkgs.callPackage ./pkgs/android-platform-tools { };
  argparse = pkgs.callPackage ./pkgs/argparse { };
  autognirehtet = pkgs.callPackage ./pkgs/AutoGnirehtet { };
  cargo-sort-ck = with pkgs.rustPlatform; pkgs.callPackage ./pkgs/cargo-sort-ck {
    inherit buildRustPackage;
  };
  cdc-cognitoform-result-generator = pkgs.callPackage ./pkgs/CdC-cognitoform-result-generator { };
  # chart-cli = pkgs.haskellPackages.callPackage ./pkgs/chart-cli { };
  commix = pkgs.callPackage ./pkgs/commix { };
  compton = pkgs.callPackage ./pkgs/Compton { };
  controls-for-fake = pkgs.libsForQt5.callPackage ./pkgs/ControlsForFake  {
    inherit (self) libfake;
    FakeMicWavPlayer = self.fake-mic-wav-player;
  };
  create_ap = pkgs.callPackage ./pkgs/create_ap { };
  csview = with pkgs.rustPlatform; pkgs.callPackage ./pkgs/csview {
    inherit buildRustPackage;
  };
  day-night-plasma-wallpapers = pkgs.callPackage ./pkgs/day-night-plasma-wallpapers { };
  fake-mic-wav-player = pkgs.libsForQt5.callPackage ./pkgs/FakeMicWavPlayer {
    inherit (self) libfake argparse;
  };
  graph-cli = pkgs.callPackage ./pkgs/graph-cli { };
  haste-client = pkgs.callPackage ./pkgs/haste-client { };
  instanttee = with pkgs.rustPlatform; pkgs.callPackage ./pkgs/InstantTee {
    inherit buildRustPackage;
  };
  iptux = with pkgs; callPackage ./pkgs/iptux {
    inherit (gst_all_1) gstreamer;
    inherit (gnome2) gtk;
  };
  json-beautifier = pkgs.callPackage ./pkgs/json-beautifier { };
  juk = kdeApplications.callPackage ./pkgs/Juk { };
  keysmith = kdeApplications.callPackage ./pkgs/keysmith { };
  killbots = kdeApplications.callPackage ./pkgs/Killbots { };
  kirigami-gallery = kdeApplications.callPackage ./pkgs/KirigamiGallery { };
  kotlin-vim = with pkgs.vimUtils; pkgs.callPackage ./pkgs/kotlin-vim {
    inherit buildVimPluginFrom2Nix;
  };
  libfake = pkgs.callPackage ./pkgs/FakeLib { };
  lokalize = pkgs.libsForQt5.callPackage ./pkgs/Lokalize { };
  merge-keepass = pkgs.callPackage ./pkgs/merge-keepass { };
  mouseinfo = pkgs.callPackage ./pkgs/mouseinfo {
    inherit (self) python3-xlib;
  };
  MyVimConfig = pkgs.callPackage ./pkgs/MyVimConfig { };
  numworks-udev-rules = pkgs.callPackage ./pkgs/numworks-udev-rules { };
  parallel-ssh = pkgs.callPackage ./pkgs/parallel-ssh {
    inherit (self) ssh-python ssh2-python;
  };
  pdf2timetable = pkgs.callPackage ./pkgs/Pdf2TimeTable {
    inherit (python_with_openpyxl305.pkgs) buildPythonPackage numpy openpyxl pandas pypdf2 click;
    inherit (self) tabula-py;
  };
  pronotebot = pkgs.callPackage ./pkgs/PronoteBot {
    inherit (self) pyautogui;
  };
  pronote-timetable-fetch = pkgs.callPackage ./pkgs/pronote-timetable-fetch { };
  protify = pkgs.libsForQt512.callPackage ./pkgs/Protify { };
  pyautogui = pkgs.callPackage ./pkgs/pyautogui {
    inherit (self)
      mouseinfo
      pygetwindow
      pyrect
      pyscreeze
      python3-xlib
      pytweening;
  };
  pygetwindow = pkgs.callPackage ./pkgs/pygetwindow {
    inherit (self) pyrect;
  };
  python-iconf = pkgs.callPackage ./pkgs/python-iconf { };
  python3-xlib = pkgs.callPackage ./pkgs/python3-xlib { };
  pyrect = pkgs.callPackage ./pkgs/pyrect { };
  pyscreeze = pkgs.callPackage ./pkgs/pyscreeze { };
  pytweening = pkgs.callPackage ./pkgs/pytweening { };
  rpi-fan = pkgs.callPackage ./pkgs/rpi-fan { };
  # qradiopredict = pkgs.libsForQt5.callPackage ./pkgs/qradiopredict { };
  scripts = with pkgs; callPackage ./pkgs/Scripts {
    eom = mate.eom;
    inherit (self) sync-database parallel-ssh merge-keepass;
  };
  slick-greeter = with pkgs.gnome3; pkgs.callPackage ./pkgs/slick-greeter {
    inherit gnome-common gtk slick-greeter;
  };
  spectacle-clipboard = pkgs.libsForQt5.callPackage ./pkgs/spectacle-clipboard { };
  splat = pkgs.callPackage ./pkgs/splat { };
  ssh-python = pkgs.callPackage ./pkgs/ssh-python { };
  ssh2-python = pkgs.callPackage ./pkgs/ssh2-python { };
  sync-database = pkgs.callPackage ./pkgs/sync-database {
    inherit (self) parallel-ssh merge-keepass;
  };
  tabula-py = pkgs.callPackage ./pkgs/tabula-py {
    inherit (python_with_openpyxl305.pkgs) buildPythonPackage fetchPypi distro numpy pandas setuptools_scm setuptools;
  };
  tfk-api-unoconv = pkgs.callPackage ./pkgs/tfk-api-unoconv { };
  timetable2header = pkgs.callPackage ./pkgs/TimeTable2Header { };
  tg = pkgs.callPackage ./pkgs/tg  { };
  unoconvui = pkgs.libsForQt5.callPackage ./pkgs/UnoconvUI  { };
  vim-async = with pkgs.vimUtils; pkgs.callPackage ./pkgs/vim-async {
    inherit buildVimPluginFrom2Nix;
  };
  vim-asyncomplete = with pkgs.vimUtils; pkgs.callPackage ./pkgs/vim-asyncomplete {
    inherit buildVimPluginFrom2Nix;
  };
  vim-asyncomplete-lsp = with pkgs.vimUtils; pkgs.callPackage ./pkgs/vim-asyncomplete-lsp {
    inherit buildVimPluginFrom2Nix;
  };
  vim-lsp = with pkgs.vimUtils; pkgs.callPackage ./pkgs/vim-lsp {
    inherit (self) vim-async;
    inherit buildVimPluginFrom2Nix;
  };
  vim-lsp-settings = with pkgs.vimUtils; pkgs.callPackage ./pkgs/vim-lsp-settings {
    inherit (self) vim-async vim-lsp vim-asyncomplete vim-asyncomplete-lsp;
    inherit buildVimPluginFrom2Nix;
  };
  vim-myftplugins = with pkgs.vimUtils; pkgs.callPackage ./pkgs/vim-myftplugins {
    inherit buildVimPluginFrom2Nix;
  };
  vim-super-retab = with pkgs.vimUtils; pkgs.callPackage ./pkgs/vim-super-retab {
    inherit buildVimPluginFrom2Nix;
  };
  vim-vala = with pkgs.vimUtils; pkgs.callPackage ./pkgs/vim-vala {
    inherit buildVimPluginFrom2Nix;
  };
  voacap = pkgs.callPackage ./pkgs/voacap { };
  wavetrace = with pkgs; python3Packages.callPackage ./pkgs/Wavetrace {
    inherit (self) splat;
    inherit (python3Packages)
      buildPythonPackage
      certifi
      chardet
      click
      gdal
      idna
      requests
      shapely
      urllib3;
  };
  xmltoman = pkgs.callPackage ./pkgs/xmltoman { };
  yaml2probatree = pkgs.callPackage ./pkgs/Yaml2ProbaTree { };
} // 
# Override derivations (patches),
# I put them here so that they get evaluated
# by the CI, it's also convenient to be able
# to access them directly from the root repo
{
  patched-rofi = with pkgs; import ./pkgs/patched-rofi {
    inherit rofi-unwrapped;
  };
  patched-alacritty = with pkgs; import ./pkgs/patched-alacritty {
    inherit lib stdenvNoCC fetchFromGitHub alacritty writeScriptBin nixosVersion;
  };
  patched-tabbed = with pkgs; import ./pkgs/patched-tabbed {
    inherit tabbed fetchFromGitHub libbsd;
  };
} //
# Derivations not supported on NUR
pkgs.lib.optionalAttrs (localUsage) (rec {
  mvn2nix = pkgs.callPackage ./pkgs/mvn2nix { };
  xtreme-download-manager = pkgs.callPackage ./pkgs/xtreme-download-manager {
    inherit mvn2nix localUsage;
  };
})
)).extend (self: super: {
  modules = import ./modules { selfnur = self; };
  overlays = import ./overlays { selfnur = self; }; # nixpkgs overlays
})
