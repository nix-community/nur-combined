{
  services.openssh.enable = true;

  security.pam.loginLimits = [
    {
      domain = "*";
      type = "soft";
      item = "nofile";
      value = "40960";
    }
  ];

  time.timeZone = "Asia/Shanghai";

  i18n.supportedLocales = [
    "en_US.UTF-8/UTF-8"
    "zh_CN.GBK/GBK"
    "zh_CN.UTF-8/UTF-8"
    "zh_CN/GB2312"
  ];

  systemd.extraConfig = ''
    DefaultTimeoutStopSec=10s
  '';

  services.journald.extraConfig = ''
    SystemMaxUse=100M
  '';

  documentation.doc.enable = false;
}
