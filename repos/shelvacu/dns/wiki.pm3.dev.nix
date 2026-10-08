{ dnsData, ... }: {
  vacu.ns.vanity = 8;
  vacu.liamMail = true;
  A = dnsData.propA;
  subdomains.dl.A = dnsData.propA;
  subdomains."mailjet._6fc09692".TXT = [ "6fc09692318c08c1f0276e1d8c1a9f48" ];
}
