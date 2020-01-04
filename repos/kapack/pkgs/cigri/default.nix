{ stdenv, pkgs, fetchFromGitHub }:

stdenv.mkDerivation rec {
  name = "cigri-3.0.0";
  src = fetchFromGitHub {
    owner = "oar-team";
    repo = "cigri";
    rev = "eeadb6b34c9d1365762a6b7d6f5598ad4bc68a21";
    sha256 = "0rhq4cbmppd79bvasyvd59ki0s6r5d8ipm2xpmgc045qvgjlmabk";
  };
  
  meta = with stdenv.lib; {
    homepage = "https://github.com/oar-team/oar3";
    description = "The OAR Resources and Tasks Management System";
    license = licenses.lgpl3;
    longDescription = ''
    '';
  };
}
