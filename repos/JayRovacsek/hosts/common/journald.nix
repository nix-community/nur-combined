{ hostName }:
# The below is utilised to ensure our host has access to journald logs as per
# this: https://astro.github.io/microvm.nix/faq.html#how-to-centralize-logging-with-journald
{
  # On the host
  source = "/var/lib/microvms/${hostName}/journal";
  # In the MicroVM
  mountPoint = "/var/log/journal";
  tag = "journal";
  proto = "virtiofs";
  socket = "journal.sock";
}
