{ stdenv, fetchFromGitHub, python, pythonPackages, gamin }:

let version = "0.11"; in

pythonPackages.buildPythonApplication {
  name = "fail2ban-${version}";

  src = fetchFromGitHub {
    owner  = "fail2ban";
    repo   = "fail2ban";
    rev    = "966fa1be89dc6d161ef1afdfd912db512ac43871";
    sha256 = "1pxrhbwj6wbpvj33d68rrwm87hdvfsq4mjqiqnx588j4mmxlkpkh";
  };

  propagatedBuildInputs = [ gamin ]
    ++ (stdenv.lib.optional stdenv.isLinux pythonPackages.systemd);

  preConfigure = ''
    for i in config/action.d/sendmail*.conf; do
      substituteInPlace $i \
        --replace /usr/sbin/sendmail sendmail \
        --replace /usr/bin/whois whois
    done
  '';

  doCheck = false;

  preInstall = ''
    substituteInPlace setup.py --replace /usr/share/doc/ share/doc/
  
    # see https://github.com/NixOS/nixpkgs/issues/4968
    ${python}/bin/${python.executable} setup.py install_data --install-dir=$out --root=$out
  '';

  postInstall = let
    sitePackages = "$out/lib/${python.libPrefix}/site-packages";
  in ''
    # see https://github.com/NixOS/nixpkgs/issues/4968
    rm -rf ${sitePackages}/etc ${sitePackages}/usr ${sitePackages}/var;
    cd ${./filter.d} && cp * $out/etc/fail2ban/filter.d
  '';

  meta = with stdenv.lib; {
    homepage    = http://www.fail2ban.org/;
    description = "A program that scans log files for repeated failing login attempts and bans IP addresses";
    license     = licenses.gpl2Plus;
    maintainers = with maintainers; [ eelco lovek323 fpletz ];
    platforms   = platforms.linux ++ platforms.darwin;
  };
}
