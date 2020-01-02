{ stdenv, fetchFromGitHub, python3 }:

python3.pkgs.buildPythonApplication {
  pname = "fail2ban";
  version = "0.11.dev3-2019-12-12";

  src = fetchFromGitHub {
    owner  = "fail2ban";
    repo   = "fail2ban";
    rev    = "657b147c0d7830f3600f3dc7feaa4815a7e19fde";
    sha256 = "0ansxn7yqmjkn1cs6k9vz4n0p5p1n7pc8vm13szs1fz3lgfzkp84";
  };

  pythonPath = with python3.pkgs;
    stdenv.lib.optionals stdenv.isLinux [
      systemd
  ];

  preConfigure = ''
    for i in config/action.d/sendmail*.conf; do
      substituteInPlace $i \
        --replace /usr/sbin/sendmail sendmail \
        --replace /usr/bin/whois whois
    done

    substituteInPlace config/filter.d/dovecot.conf \
      --replace dovecot.service dovecot2.service
  '';

  doCheck = false;

  preInstall = ''
    substituteInPlace setup.py --replace /usr/share/doc/ share/doc/

    # see https://github.com/NixOS/nixpkgs/issues/4968
    ${python3.interpreter} setup.py install_data --install-dir=$out --root=$out
  '';

  postPatch = ''
    ${stdenv.shell} ./fail2ban-2to3
  '';

  postInstall = let
    sitePackages = "$out/${python3.sitePackages}";
  in ''
    # see https://github.com/NixOS/nixpkgs/issues/4968
    rm -rf ${sitePackages}/etc ${sitePackages}/usr ${sitePackages}/var;

    # Add custom filters
    cd ${./filter.d} && cp * $out/etc/fail2ban/filter.d
  '';

  meta = with stdenv.lib; {
    homepage    = https://www.fail2ban.org/;
    description = "A program that scans log files for repeated failing login attempts and bans IP addresses";
    license     = licenses.gpl2Plus;
    maintainers = with maintainers; [ eelco lovek323 fpletz ];
    platforms   = platforms.linux ++ platforms.darwin;
  };
}
