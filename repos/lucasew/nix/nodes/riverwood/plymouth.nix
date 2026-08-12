{ pkgs, ... }:
{
  boot.plymouth = {
    enable = true;
    theme = "breeze";
    logo = pkgs.plymouthSvgLogo {
      url = "https://static.wikia.nocookie.net/elderscrolls/images/7/74/SettlementWhite.svg";
      sha256 = "00k9gm34i05rjia1ljglv7x3kp3a0q3kfv88dh8lar7hilq0w6l1";
    };
  };
}
