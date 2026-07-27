
{ pkgs, inputs, lib, ...}:
{
  imports = [
    inputs.nix-wsl.nixosModules.wsl
  ];

  wsl.enable = true;

  wsl.wslConf.user.default = lib.mkForce "me";
  wsl.interop.register = true;

  environment.systemPackages = [
  (pkgs.writeShellScriptBin "pw" ''
    /mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe
    ''
  )
  (pkgs.writeShellScriptBin "psh" ''
    /mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe
    ''
  )
  ];

  wsl.nativeSystemd = true;
  wsl.wslConf.interop.appendWindowsPath = true;

  programs.bash.loginShellInit = "";

  services.openssh = {
    enable = true;
    ports = [ 2222 ];

    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
    settings.X11Forwarding = true;
    extraConfig = ''
      X11UseLocalhost no
    '';
  };

}
