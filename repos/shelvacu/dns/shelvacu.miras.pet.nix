{ dnsData, ... }:
{
  vacu.liamMail = true;
  A = dnsData.propA;
}
