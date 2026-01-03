{ dnsData, ... }:
{
  vacu.liamMail = true;
  A = dnsData.propA;
  subdomains = {
    www.A = dnsData.propA;
    shop.A = dnsData.propA;
  };
}
