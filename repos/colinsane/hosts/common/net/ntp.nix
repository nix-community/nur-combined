# NTP and DNS/DNSSEC have a chicken-and-egg issue:
# - NTP needs to resolve DNS to know how to query the servers (`0.nixos.pool.ntp.org`, etc)
# - DNS needs to have a semi-accurate clock to validate DNSSEC for resolutions
#
# nixos and systemd-timesyncd overcome this in the default installation by:
# - setting `SYSTEMD_NSS_RESOLVE_VALIDATE=0` in the systemd-timesyncd.service unit file
# - systemd nss module which plumbs that to systemd-resolved
# that ONLY WORKS if using systemd-resolved.
#
# my alternative fix here is to hardcode a list of fallback NTP IP addresses, to use when DNS resolution of the primaries fails.
#
# lastly, the clock can be manually set:
# - `systemctl stop systemd-timesyncd`
# - `sudo timedatectl --adjust-system-clock set-time '2024-01-01 00:00:01 UTC'`
# - `systemctl start systemd-timesyncd`
#
# XXX(2024-12-03): i fixed the NTP-DNS circularity by exempting `pool.ntp.org` from DNSSEC validation in unbound conf
{ config, ... }:
{
  # services.timesyncd.servers = config.networking.timeServers;
  # services.timesyncd.fallbackServers = [
  #   "129.6.15.28"  # time-a-g.nist.gov
  #   "132.163.97.1"  # time-a-wwv.nist.gov
  #   "132.163.96.1"  # time-a-b.nist.gov
  #   "128.138.140.44"  # utcnist.colorado.edu
  #   "162.159.200.1"  # time.cloudflare.com
  # ];

  # more feature-complete NTP implementations exist, like `chrony`, should i ever wish to also be a NTP **server**:
  # services.chrony.enable = true;
  # services.chrony.enableNTS = true;
}
