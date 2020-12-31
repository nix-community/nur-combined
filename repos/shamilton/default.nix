{ pkgs ? import <nixpkgs> {}
, localUsage ? false
}:
let
  python_with_openpyxl305 = pkgs.python38.override {
    packageOverrides = self: super: {
      openpyxl = pkgs.python38Packages.openpyxl.overrideAttrs (old: {
        version = "3.0.5";
        src = pkgs.python38Packages.fetchPypi {
          pname = "openpyxl";
          version = "3.0.5";
          sha256 = "06y7lbqnn0ga2x55az4hkqfs202fl6mkv3m5h0js2a01cnd1zq8q";
        };
      });
    };
  };
in
rec {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays
  
  android-platform-tools = pkgs.callPackage ./pkgs/android-platform-tools { };
  anystyle-cli = pkgs.callPackage ./pkgs/anystyle-cli { };
  argparse = pkgs.callPackage ./pkgs/argparse { };
  baobab = pkgs.callPackage ./pkgs/baobab { };
  boca = pkgs.callPackage ./pkgs/boca { inherit smooth; };
  bomber = pkgs.kdeApplications.callPackage ./pkgs/Bomber { };
  cargo-sort-ck = with pkgs.rustPlatform; pkgs.callPackage ./pkgs/cargo-sort-ck {
    inherit buildRustPackage;
  };
  compton = pkgs.callPackage ./pkgs/Compton { };
  controls-for-fake = pkgs.libsForQt5.callPackage ./pkgs/ControlsForFake  {
    inherit libfake;
    FakeMicWavPlayer = fake-mic-wav-player;
  };
  day-night-plasma-wallpapers = with pkgs.python3Packages; pkgs.callPackage ./pkgs/day-night-plasma-wallpapers { 
    dbus-python = dbus-python;
  };
  fake-mic-wav-player = pkgs.libsForQt5.callPackage ./pkgs/FakeMicWavPlayer {
    inherit libfake argparse;
  };
  freac = pkgs.callPackage ./pkgs/freac { inherit boca smooth; };
  haste-client = pkgs.callPackage ./pkgs/haste-client { };
  inkscape = pkgs.callPackage ./pkgs/inkscape-1.0 { 
    lcms = pkgs.lcms2;
  };
  juk = pkgs.kdeApplications.callPackage ./pkgs/Juk { };
  kapptemplate = pkgs.kdeApplications.callPackage ./pkgs/KAppTemplate { };
  kbreakout = pkgs.kdeApplications.callPackage ./pkgs/KBreakOut { };
  keysmith = pkgs.kdeApplications.callPackage ./pkgs/keysmith { };
  killbots = pkgs.kdeApplications.callPackage ./pkgs/Killbots { };
  kirigami-gallery = pkgs.kdeApplications.callPackage ./pkgs/KirigamiGallery { };
  ksmoothdock = pkgs.libsForQt5.callPackage ./pkgs/ksmoothdock { };
  libfake = pkgs.callPackage ./pkgs/FakeLib { };
  lokalize = pkgs.libsForQt5.callPackage ./pkgs/Lokalize { };
  merge-keepass = with pkgs.python3Packages; pkgs.callPackage ./pkgs/merge-keepass { 
    inherit buildPythonPackage pykeepass click pytest;
  };
  mouseinfo = with pkgs.python38Packages; pkgs.callPackage ./pkgs/mouseinfo {
    inherit buildPythonPackage fetchPypi pyperclip python3-xlib pillow;
  };
  ncgopher = pkgs.callPackage ./pkgs/ncgopher { };
  numworks-udev-rules = pkgs.callPackage ./pkgs/numworks-udev-rules { };
  parallel-ssh = with pkgs.python3Packages; pkgs.callPackage ./pkgs/parallel-ssh {
    inherit buildPythonPackage setuptools fetchPypi paramiko gevent ssh2-python;
  };
  pdf2timetable = pkgs.callPackage ./pkgs/Pdf2TimeTable {
    inherit (python_with_openpyxl305.pkgs) buildPythonPackage numpy openpyxl pandas pypdf2 click;
    inherit tabula-py;
  };
  pronotebot = with pkgs.python3Packages; pkgs.callPackage ./pkgs/PronoteBot {
    inherit buildPythonPackage pybase64 selenium click pyautogui;
    inherit (pkgs.python3Packages) wget;
  };
  pronote-timetable-fetch = pkgs.callPackage ./pkgs/pronote-timetable-fetch {
  };
  ptouch-print = pkgs.callPackage ./pkgs/ptouch-print { };
  pyautogui = with pkgs.python3Packages; pkgs.callPackage ./pkgs/pyautogui {
  inherit
    buildPythonPackage
    fetchPypi
    mouseinfo
    pygetwindow
    pymsgbox
    pyrect
    pyscreeze
    python3-xlib
    pytweening;
  };
  pygetwindow = with pkgs.python3Packages; pkgs.callPackage ./pkgs/pygetwindow {
    inherit buildPythonPackage fetchPypi pyrect;
  };
  python-iconf = with pkgs.python3Packages; pkgs.callPackage ./pkgs/python-iconf {
    inherit buildPythonPackage fetchPypi pytest;
  };
  python3-xlib = with pkgs.python3Packages; pkgs.callPackage ./pkgs/python3-xlib {
    inherit buildPythonPackage fetchPypi;
  };
  pyrect = with pkgs.python3Packages; pkgs.callPackage ./pkgs/pyrect {
    inherit buildPythonPackage fetchPypi;
  };
  pyscreeze = with pkgs.python3Packages; pkgs.callPackage ./pkgs/pyscreeze {
    inherit buildPythonPackage fetchPypi pillow;
  };
  pytweening = with pkgs.python3Packages; pkgs.callPackage ./pkgs/pytweening {
    inherit buildPythonPackage;
  };
  qtile = pkgs.callPackage ./pkgs/qtile { };
  rofi = pkgs.callPackage ./pkgs/rofi { };
  semantik = pkgs.libsForQt5.callPackage ./pkgs/semantik { };
  scripts = with pkgs.python3Packages; pkgs.callPackage ./pkgs/Scripts {
    eom = pkgs.mate.eom;
    inherit sync-database buildPythonPackage parallel-ssh merge-keepass;
  };
  slick-greeter = with pkgs.gnome3; pkgs.callPackage ./pkgs/slick-greeter {
    inherit gnome-common gtk slick-greeter;
  };
  smooth = with pkgs.gnome3; pkgs.callPackage ./pkgs/smooth { inherit gtk; };
  spectacle-clipboard = pkgs.libsForQt5.callPackage ./pkgs/spectacle-clipboard { };
  ssh2-python = with pkgs.python3Packages; pkgs.callPackage ./pkgs/ssh2-python {
    inherit buildPythonPackage fetchPypi cython setuptools pytest;
  };
  super-tux-kart = pkgs.callPackage ./pkgs/SuperTuxKart {
    inherit wiiuse;
  };
  sync-database = with pkgs.python3Packages; pkgs.callPackage ./pkgs/sync-database {
    inherit buildPythonPackage parallel-ssh merge-keepass pykeepass;
  };
  tabula-py = pkgs.callPackage ./pkgs/tabula-py {
    inherit (python_with_openpyxl305.pkgs) buildPythonPackage fetchPypi distro numpy pandas setuptools_scm setuptools;
  };
  timetable2header = with pkgs.python3Packages; pkgs.callPackage ./pkgs/TimeTable2Header {
    inherit buildPythonPackage click pandas numpy odfpy;
  };
  unoconvui = pkgs.libsForQt5.callPackage ./pkgs/UnoconvUI  { };
  vokoscreen-ng = with pkgs; libsForQt5.callPackage ./pkgs/vokoscreenNG {
    gstreamer = gst_all_1.gstreamer;
    gst-plugins-base = gst_all_1.gst-plugins-base;
    gst-plugins-good = gst_all_1.gst-plugins-good;
    gst-plugins-bad = gst_all_1.gst-plugins-bad;
    gst-plugins-ugly = gst_all_1.gst-plugins-ugly;
  };
  wiiuse = pkgs.callPackage ./pkgs/WiiUse { };
  yaml2probatree = with pkgs.python3Packages; pkgs.callPackage ./pkgs/Yaml2ProbaTree {
    inherit buildPythonPackage pyyaml click;
  };
} //
# Derivations not supported on NUR
pkgs.lib.optionalAttrs (localUsage) (rec {
  mvn2nix = pkgs.callPackage ./pkgs/mvn2nix { };
  xtreme-download-manager = pkgs.callPackage ./pkgs/xtreme-download-manager {
    inherit mvn2nix;
  };
})
