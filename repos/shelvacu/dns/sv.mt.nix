{ dnsData, ... }:
let
  inherit (dnsData) propA;
in
{
  vacu.ns.vanity = 5;
  vacu.liamMail = true;
  A = propA;
  subdomains = {
    # keep-sorted start block=yes
    "2e14".A = propA;
    "clientauth.2e14".A = propA;
    "copy".A = propA;
    "copyparty".A = propA;
    "f".A = propA;
    "fs".A = propA;
    "files".A = propA;
    "jf".A = propA;
    # this points to javi public IP, and makes it so java does not have to type a long domain.
    "js".CNAME = [ "ssh.javamurray.com." ];
    "mailjet._bb92e04e".TXT = [ "bb92e04e54b23491b8189653eba988ca" ];
    "thisthirdlevelisownedbyshelandwasnotmadeavailabletoemily".NS = [
      "thisns1isonlyusedbyshelandisnotusedforthirdlevelregistrationfor.emilygeil.com."
      "thisns2isonlyusedbyshelandisnotusedforthirdlevelregistrationfor.emilygeil.com."
      "thisns3isonlyusedbyshelandisnotusedforthirdlevelregistrationfor.emilygeil.com."
      "thisns4isonlyusedbyshelandisnotusedforthirdlevelregistrationfor.emilygeil.com."
      "thisns5isonlyusedbyshelandisnotusedforthirdlevelregistrationfor.emilygeil.com."
    ];
    "www".A = propA;
    # keep-sorted end
  };
}
