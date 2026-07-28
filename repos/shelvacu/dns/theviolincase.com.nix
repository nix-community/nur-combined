{ dnsData, ... }: {
  vacu.liamMail = true;
  vacu.ns.vanity = 8;
  A = dnsData.propA;
  subdomains = {
    www.A = dnsData.propA;
    shop = {
      A = dnsData.propA;
      vacu.liamMail = true;
    };
  };
}
