{ dnsData, ... }:
{
  vacu.liamMail = true;
  vacu.defaultCAA = true;
  A = dnsData.propA;
}
