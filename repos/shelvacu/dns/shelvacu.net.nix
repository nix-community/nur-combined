{ dnsData, ... }: {
  vacu.ns.vanity = 8;
  A = dnsData.propA;
  subdomains.www.A = dnsData.propA;
}
