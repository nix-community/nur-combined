{
  amdgpu-common = import ./services/hardware/amdgpu-common.nix;
  amdgpu-fan = import ./services/hardware/amdgpu-fan.nix;
  amdgpu-pwm = import ./services/hardware/amdgpu-pwm.nix;
  betanin = import ./services/web-apps/betanin.nix;
  dunst = import ./services/x11/dunst.nix;
  koillection = import ./services/web-apps/koillection.nix;
  porkbun-ddns = import ./services/networking/porkbun-ddns.nix;
  radeon-profile-daemon = import ./services/hardware/radeon-profile-daemon.nix;
}

