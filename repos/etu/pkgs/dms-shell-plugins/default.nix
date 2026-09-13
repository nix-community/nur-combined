{
  lib,
  callPackage,
  ...
}:
lib.recurseIntoAttrs {
  activateLinux = callPackage ./activate-linux.nix {};
  calculator = callPackage ./calculator.nix {};
  catWidget = callPackage ./cat-widget.nix {};
  dgpuStatus = callPackage ./dgpu-status.nix {};
  dmsScreenshot = callPackage ./dms-screenshot.nix {};
  emojiLauncher = callPackage ./emoji-launcher.nix {};
  fullscreenPowerMenu = callPackage ./fullscreen-power-menu.nix {};
  hiddenBar = callPackage ./hidden-bar.nix {};
  modernClock = callPackage ./modern-clock.nix {};
  networkIndicator = callPackage ./network-indicator.nix {};
  niriWindows = callPackage ./niri-windows.nix {};
  nixPackageRunner = callPackage ./nix-package-runner.nix {};
  powerOptions = callPackage ./power-options.nix {};
  quickCapture = callPackage ./quick-capture.nix {};
  recentFiles = callPackage ./recent-files.nix {};
  resourceMonitor = callPackage ./resource-monitor.nix {};
  simpleAudioControl = callPackage ./simple-audio-control.nix {};
  systemMonitorPlus = callPackage ./system-monitor-plus.nix {};
  timeUntil = callPackage ./time-until.nix {};
  unifiedTaskbar = callPackage ./unified-taskbar.nix {};
  vscodeLauncher = callPackage ./vscode-launcher.nix {};
  wallpaperCarousel = callPackage ./wallpaper-carousel.nix {};
  webSearch = callPackage ./web-search.nix {};
  wienerLinien = callPackage ./wiener-linien.nix {};
  worldClock = callPackage ./world-clock.nix {};
}
