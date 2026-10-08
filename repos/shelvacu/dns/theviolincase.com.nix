{ dnsData, ... }: {
  vacu.liamMail = true;
  vacu.ns.vanity = 8;
  A = dnsData.propA;
  subdomains = {
    www.A = dnsData.propA;
    "mailjet._2d9c44cf".TXT = [ "2d9c44cf835dacc5fbec9af23791af55" ];
    shop = {
      A = dnsData.propA;
      vacu.liamMail = true;
    };
  };
}
