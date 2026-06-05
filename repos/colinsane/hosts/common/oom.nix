# out-of-memory killer
# - <https://discourse.nixos.org/t/avoid-linux-locking-up-in-low-memory-situations-using-earlyoom/22072>
{ ... }:
{
  # earlyoom is a userspace OOM-killer daemon (v.s. in-kernel)
  # default is to SIGTERM @ 10% free memory, SIGKILL @ 5%. ditto for swap space.
  services.earlyoom.enable = true;
  services.earlyoom.freeMemThreshold = 6;  # in terms of % of installed RAM
  # TODO: can configure preferred things to kill / keep alive:
  # services.earlyoom.extraArgs = [
  #   "-g"
  #   "--avoid" "^(X|init|Xorg|ssh|gnome.*|ghostty|kwin)$"
  #   "--prefer "^(electron|libreoffice|gimp|zen*)$"
  # ];
}
