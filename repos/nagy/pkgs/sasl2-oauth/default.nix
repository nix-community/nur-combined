{ stdenv, lib, fetchFromGitHub, autoreconfHook, cyrus_sasl, pkgs, ... }:

stdenv.mkDerivation rec {
  pname = "sasl2-oauth";
  version = "unstable-2021-01-27";
  src = fetchFromGitHub {
    owner = "robn";
    repo = "sasl2-oauth";
    rev = "4236b6fb904d836b85b55ba32128b843fd8c2362";
    sha256 = "17c1131yy41smz86fkb6rywfqv3hpn0inqk179a4jcr1snsgr891";
  };
  nativeBuildInputs = [ autoreconfHook ];
  buildInputs = [ cyrus_sasl ];
  meta = with lib; {
    inherit (src.meta) homepage;
    description = "An OAuth plugin for libsasl2";
    license = with licenses; [ mit ];
  };
}
