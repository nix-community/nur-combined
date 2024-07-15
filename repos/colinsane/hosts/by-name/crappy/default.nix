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

  sane.programs.blueberry.enableFor.user.colin = false;  # bluetooth manager: doesn't cross compile!
  # sane.programs.brave.enableFor.user.colin = false;  # 2024/06/03: fails eval if enabled on cross
  # sane.programs.firefox.enableFor.user.colin = false;  # 2024/06/03: this triggers an eval error in yarn stuff -- i'm doing IFD somewhere!!?
  sane.programs.mepo.enableFor.user.colin = false;  # 2024/06/04: doesn't cross compile (nodejs)
  sane.programs.mercurial.enableFor.user.colin = false;  # 2024/06/03: does not cross compile
  sane.programs.nixpkgs-review.enableFor.user.colin = false;  # 2024/06/03: OOMs when cross compiling
  sane.programs.ntfy-sh.enableFor.user.colin = false;  # 2024/06/04: doesn't cross compile (nodejs)
  sane.programs.pwvucontrol.enableFor.user.colin = false;  # 2024/06/03: doesn't cross compile (libspa-sys)
  sane.programs."sane-scripts.bt-search".enableFor.user.colin = false;  # 2024/06/03: does not cross compile
  sane.programs.sequoia.enableFor.user.colin = false;  # 2024/06/03: does not cross compile
  sane.programs.zathura.enableFor.user.colin = false;  # 2024/06/03: does not cross compile
}
