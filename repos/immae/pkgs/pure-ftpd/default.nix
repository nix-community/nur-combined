{ ldapFtpId ? null
, stdenv, fetchurl, openssl, postgresql, openldap }:

stdenv.mkDerivation rec {
  name = "pure-ftpd-1.0.47";

  src = fetchurl {
    url = "https://download.pureftpd.org/pub/pure-ftpd/releases/${name}.tar.gz";
    sha256 = "1b97ixva8m10vln8xrfwwwzi344bkgxqji26d0nrm1yzylbc6h27";
  };

  preConfigure = stdenv.lib.optionalString (!isNull ldapFtpId) ''
    sed -i -e "s#FTPuid#${ldapFtpId}Uid#" src/log_ldap.h
    sed -i -e "s#FTPgid#${ldapFtpId}Gid#" src/log_ldap.h
    '';
  postConfigure = ''
    sed -i 's/define MAX_DATA_SIZE (40/define MAX_DATA_SIZE (70/' src/ftpd.h
    '';
  buildInputs = [ openssl postgresql openldap ];

  configureFlags = [ "--with-everything" "--with-tls" "--with-pgsql" "--with-ldap" ];

  meta = with stdenv.lib; {
    description = "A free, secure, production-quality and standard-conformant FTP server";
    homepage = https://www.pureftpd.org;
    license = licenses.isc; # with some parts covered by BSD3(?)
    maintainers = [ maintainers.lethalman ];
    platforms = platforms.linux;
  };
}
