{ dnsData, ... }: {
  A = dnsData.propA;
  subdomains.www.A = dnsData.propA;
  vacu.liamMail = true;
  vacu.ns.vanity = 4;
}
