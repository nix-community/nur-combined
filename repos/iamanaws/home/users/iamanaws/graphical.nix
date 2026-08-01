{
  lib,
  hostConfig,
  ...
}:
{
  config = lib.optionalAttrs hostConfig.isGraphical {
    programs.brave = {
      enable = true;
      extensions = [
        "nngceckbapebfimnlniiiahkandclblb" # bitwarden
        "ghmbeldphafepmbegfdlkpapadhbakde" # proton pass
        "dphilobhebphkdjbpfohgikllaljmgbn" # simplelogin
        "fnaicdffflnofjppbagibeoednhnbjhg" # floccus
        "cjpalhdlnbpafiamejdnhcphjbkeiagm" # ublock origin
        "pkehgijcmpdhfbdbbnkijodmdjhbjlgp" # privacy badger
        "oldceeleldhonbafppcapldpdifcinji" # language tool
        "lnjaiaapbakfhlbjenjkhffcdpoompki" # catppuccin github icons
        "nffaoalbilbmmfgbnbgppjihopabppdk" # video speed controller
        "gppongmhjkpfnbhagpmjfkannfbllamg" # wappalyzer
      ];

      commandLineArgs =
        lib.optionals hostConfig.isLinux [
          "--password-store=gnome-libsecret"
        ]
        ++ [
          # "--enable-features=UseOzonePlatform "
          # "--ozone-platform=x11"
        ];
    };
  };
}
