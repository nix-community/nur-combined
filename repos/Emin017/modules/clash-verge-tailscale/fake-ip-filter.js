// tailscaled can bypass Clash TUN, so its control-plane traffic needs real IPs.
function main(config, profileName) {
  const dns = config.dns || {};
  dns["fake-ip-filter"] = [
    ...new Set([...(dns["fake-ip-filter"] || []), "+.tailscale.com"]),
  ];
  config.dns = dns;
  return config;
}
