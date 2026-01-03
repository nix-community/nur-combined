{ dnsData, ... }:
let
  inherit (dnsData) propA;
in
{
  vacu.liamMail = true;
  A = propA;
  subdomains = {
    # keep-sorted start block=yes
    "2e14".A = propA;
    "clientauth.2e14".A = propA;
    "copy".A = propA;
    "copyparty".A = propA;
    "f".A = propA;
    "files".A = propA;
    "jf".A = propA;
    thisthirdlevelisownedbyshelandwasnotmadeavailabletoemily.NS = [
      "thisns1isonlyusedbyshelandisnotusedforthirdlevelregistrationfor.emilygeil.com."
      "thisns2isonlyusedbyshelandisnotusedforthirdlevelregistrationfor.emilygeil.com."
      "thisns3isonlyusedbyshelandisnotusedforthirdlevelregistrationfor.emilygeil.com."
      "thisns4isonlyusedbyshelandisnotusedforthirdlevelregistrationfor.emilygeil.com."
      "thisns5isonlyusedbyshelandisnotusedforthirdlevelregistrationfor.emilygeil.com."
    ];
    www.A = propA;
    # keep-sorted end
  };
}
