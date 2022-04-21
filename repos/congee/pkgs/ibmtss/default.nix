{ stdenv
, lib
, fetchgit
, autoreconfHook
, openssl
, pkg-config
, ...
}:

stdenv.mkDerivation rec {
  pname = "ibmtss";
  version = "1.6.0";

  src = fetchgit {
    url = "https://github.com/kgoldman/ibmtss";
    rev = "c4e131e34ec0ed09411aa3bc76f76129ef881573";
    sha256 = "sha256-NDJa7aoifqbZxSNtqf/9SnoX3MCXDPZjHTU16nz2RWw=";
  };

  buildInputs = [ pkg-config autoreconfHook ];
  nativeBuildInputs = [ openssl ];

  meta = with lib; {
    description = "User space TSS for TPM 2.0 by IBM.";
    longDescription = "This is a user space TSS for TPM 2.0. It implements the functionality equivalent to (but not API compatible with) the TCG TSS working group's ESAPI, SAPI, and TCTI API's (and perhaps more) but with a hopefully simpler interface.";
    homepage = "https://sourceforge.net/projects/ibmtpm20tss";
    licenses = licenses.bsd3;
    maintainers = with maintainers; [ congee ];
  };
}
