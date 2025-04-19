{ config, ... }:
{
  home.sessionVariables.ANDROID_USER_HOME = "${config.xdg.configHome}/android";
}
