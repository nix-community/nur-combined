{ stdenv, lib, fetchFromGitHub, autoreconfHook, cyrus_sasl, sasl2-oauth, isync
}:

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

  passthru = rec {
    cyrus_sasl_oauth = cyrus_sasl.overrideAttrs (old: rec {
      postInstall = (old.postInstall or "") + ''
        for lib in ${sasl2-oauth}/lib/sasl2/*; do
          ln -sf $lib $out/lib/sasl2/
        done
      '';
    });
    isync_oauth = isync.override { cyrus_sasl = cyrus_sasl_oauth; };
  };

  meta = with lib; {
    inherit (src.meta) homepage;
    description = "An OAuth plugin for libsasl2";
    license = with licenses; [ mit ];
  };
}
