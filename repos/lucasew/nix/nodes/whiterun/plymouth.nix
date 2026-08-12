{ pkgs, ... }:
{
  boot.plymouth = {
    enable = true;
    theme = "breeze";
    logo = pkgs.plymouthSvgLogo {
      url = "https://static.wikia.nocookie.net/elderscrolls/images/6/64/Whiterun.svg";
      sha256 = "1fqg4jk0ia1hp2mxvz9gxbxg337k4iwim9kbvdz4l99v886532g4";
    };
  };
}
