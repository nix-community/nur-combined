{ dnsData, ... }: {
  vacu.ns.vanity = 4;
  vacu.liamMail = true;
  A = dnsData.propA;
  subdomains.www.A = dnsData.propA;
}
