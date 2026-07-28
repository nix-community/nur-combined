{ dnsData, ... }: {
  vacu.ns.vanity = 8;
  vacu.liamMail = true;
  A = dnsData.propA;
  subdomains.dl.A = dnsData.propA;
}
