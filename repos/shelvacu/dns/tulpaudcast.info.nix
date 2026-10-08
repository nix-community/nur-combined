{ dnsData, ... }: {
  vacu.ns.vanity = 4;
  vacu.liamMail = true;
  A = dnsData.propA;
  subdomains."mailjet._cb530a52".TXT = [ "cb530a52fdc77300c2d2e84ecdcadf08" ];
  subdomains.www.A = dnsData.propA;
}
