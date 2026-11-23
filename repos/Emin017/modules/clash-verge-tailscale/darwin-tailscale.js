// Tailscale compatibility for macOS Network Extension and Clash TUN.
function main(config, profileName) {
  const tailnet = "@tailnet@";
  const tailnetPattern = "+." + tailnet;
  const dns = config.dns || {};
  dns["nameserver-policy"] = {
    ...(dns["nameserver-policy"] || {}),
    // macOS does not provide a stable tailscale0 interface for DNS binding.
    [tailnetPattern]: "100.100.100.100",
  };
  dns["fake-ip-filter"] = [
    ...new Set([
      ...(dns["fake-ip-filter"] || []),
      tailnetPattern,
      "+.tailscale.com",
      "+.tailscale.io",
    ]),
  ];
  config.dns = dns;

  config.tun = config.tun || {};
  config.tun["route-exclude-address"] = [
    ...new Set([
      ...(config.tun["route-exclude-address"] || []),
      "100.64.0.0/10",
      "fd7a:115c:a1e0::/48",
    ]),
  ];

  const tailscaleRules = [
    "PROCESS-NAME,io.tailscale.ipn.macsys.network-extension,DIRECT",
    "DOMAIN-SUFFIX,tailscale.com,DIRECT",
    "DOMAIN-SUFFIX,tailscale.io,DIRECT",
    "IP-CIDR,100.64.0.0/10,DIRECT,no-resolve",
    "IP-CIDR6,fd7a:115c:a1e0::/48,DIRECT,no-resolve",
  ];
  config.rules = [
    ...tailscaleRules,
    ...(config.rules || []).filter((rule) => !tailscaleRules.includes(rule)),
  ];
  return config;
}
