{ dnsData, ... }:
{
  A = dnsData.propA;
  subdomains.www.A = dnsData.propA;
}
