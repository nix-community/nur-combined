{ dnsData, ... }:
{
  vacu.liamMail = true;
  A = dnsData.propA;
  subdomains.www.A = dnsData.propA;
  subdomains.shop.A = dnsData.propA;
}
