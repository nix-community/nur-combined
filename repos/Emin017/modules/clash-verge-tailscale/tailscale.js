// Keep this tailnet's MagicDNS and connections on the Tailscale interface.
function main(config, profileName) {
  const tailnet = "@tailnet@";
  const tailnetPattern = "+." + tailnet;
  const proxyName = "TAILSCALE";
  const dns = config.dns || {};
  dns["nameserver-policy"] = {
    ...(dns["nameserver-policy"] || {}),
    [tailnetPattern]: ["100.100.100.100#@tailscaleInterface@"],
  };
  // tailscaled marks control-plane traffic to bypass TUN; never return Fake-IPs.
  dns["fake-ip-filter"] = [
    ...new Set([
      ...(dns["fake-ip-filter"] || []),
      tailnetPattern,
      "+.tailscale.com",
    ]),
  ];
  config.dns = dns;
  // Plain DIRECT may bind to the physical interface selected by TUN mode.
  config.proxies = [
    { name: proxyName, type: "direct", "interface-name": "@tailscaleInterface@" },
    ...(config.proxies || []).filter((proxy) => proxy.name !== proxyName),
  ];
  const tailnetRules = [
    "DOMAIN-SUFFIX," + tailnet + "," + proxyName,
    "IP-CIDR,100.64.0.0/10," + proxyName + ",no-resolve",
    "IP-CIDR6,fd7a:115c:a1e0::/48," + proxyName + ",no-resolve",
  ];
  config.rules = [
    ...tailnetRules,
    ...(config.rules || []).filter((rule) => !tailnetRules.includes(rule)),
  ];
  return config;
}
