{ stdenv, iputils, fetchpatch, fetchurl, file, hostname, perl, openssl,
  bind, openldap, procps-ng, postfix,
  wrapperDir ? "/run/wrappers/bin"
}:
stdenv.mkDerivation rec {
  pname = "monitoring-plugins";
  version = "2.2";
  name = "${pname}-${version}";

  src = fetchurl {
    url = "https://www.monitoring-plugins.org/download/${name}.tar.gz";
    sha256 = "0r9nvnk64nv7k8w352n99lw4p92pycxd9wlga9zyzjx9027m6si9";
  };

  patches = [
    (fetchpatch {
      name = "mariadb.patch";
      url = "https://git.archlinux.org/svntogit/community.git/plain/trunk/0001-mariadb.patch?h=packages/monitoring-plugins";
      sha256 = "0jf6fqkyzag66rid92m7asnr2dp8rr8kn4zjvhqg0mqvf8imppky";
    })
  ];

  # ping needs CAP_NET_RAW capability which is set only in the wrappers namespace
  configurePhase = ''
    ./configure --disable-static --disable-dependency-tracking \
      --prefix=$out \
      --with-ping-command="${wrapperDir}/ping -4 -n -U -w %d -c %d %s" \
      --with-ping6-command="${wrapperDir}/ping -6 -n -U -w %d -c %d %s" \
      --with-sudo-command="${wrapperDir}/sudo"
  '';

  buildInputs = [ perl file hostname iputils openssl openldap procps-ng bind.dnsutils postfix ];
}
