{ dnsData, ... }: {
  vacu.liamMail = true;
  vacu.ns.vanity = 8;
  A = dnsData.propA;
  subdomains."mailjet._82a02065".TXT = [ "82a0206502c02074d53ea813b6d18943" ];
  subdomains.www.A = dnsData.propA;
}
