# Samsung chromebook XE303C12
# - <https://wiki.postmarketos.org/wiki/Samsung_Chromebook_(google-snow)>
{ ... }:
{
  imports = [
    ./fs.nix
  ];

  sane.hal.samsung.enable = true;
  sane.roles.client = true;
  # sane.roles.pc = true;

  users.users.colin.initialPassword = "147147";
  sane.programs.sway.enableFor.user.colin = true;

  sane.programs.calls.enableFor.user.colin = false;
  sane.programs.consoleMediaUtils.enableFor.user.colin = true;
  sane.programs.epiphany.enableFor.user.colin = true;
  sane.programs.geary.enableFor.user.colin = false;
  # sane.programs.firefox.enableFor.user.colin = true;
  sane.programs.portfolio-filemanager.enableFor.user.colin = true;
  sane.programs.signal-desktop.enableFor.user.colin = false;
  sane.programs.wike.enableFor.user.colin = true;

  sane.programs.dino.config.autostart = false;
  sane.programs.dissent.config.autostart = false;
  sane.programs.fractal.config.autostart = false;
  sane.programs.sway.config.mod = "Mod1";  #< alt key instead of Super

  # sane.programs.guiApps.enableFor.user.colin = false;

  # sane.programs.pcGuiApps.enableFor.user.colin = false;  #< errors!
}
