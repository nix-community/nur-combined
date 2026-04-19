{
  flake.modules.nixos.i18n = {
    console = {
      # font = "LatArCyrHeb-16";
      keyMap = "us";
    };
    time.timeZone = "Asia/Singapore";
    i18n.defaultLocale = "en_US.UTF-8";
  };
}
