{ dnsData, ... }: {
  vacu.ns.vanity = 4;
  vacu.liamMail = true;
  A = dnsData.propA;
  subdomains."mailjet._9cf0e516".TXT = [ "9cf0e516f9f75b0427ee8adff4f04dfa" ];
  subdomains.www.A = dnsData.propA;
}
