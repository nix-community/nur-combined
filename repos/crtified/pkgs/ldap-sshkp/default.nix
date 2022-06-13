{ fetchFromGitHub, mkDerivation, base, bytestring, cmdargs, hpack, ldap-client, lib
, text
}:
mkDerivation {
  pname = "ldap-sshkp";
  version = "0.1.0.0";
  src = fetchFromGitHub {
    owner = "CRTified";
    repo = "ldap-sshkp";
    rev = "695886dcc7bbf9c398ce857e42dbf311149c54f7";
    hash = "sha256-fnSqYeFUkucUzJ8EdLDtseoVEW7KPjNvwPoRiDsRL+g=";
  };
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends = [
    base bytestring cmdargs ldap-client text
  ];
  libraryToolDepends = [ hpack ];
  executableHaskellDepends = [
    base bytestring cmdargs ldap-client text
  ];
  testHaskellDepends = [ base bytestring cmdargs ldap-client text ];
  prePatch = "hpack";
  homepage = "https://github.com/CRTified/ldap-sshkp#readme";
  license = lib.licenses.agpl3Only;
}
