{
  lib,
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  perl,
  perlPackages,
  libpcap,
  curl
}:
stdenv.mkDerivation rec {
  pname = "ipv6toolkit";
  version = "2.2";

  src = fetchFromGitHub {
    owner = "fgont";
    repo = pname;
    tag = "v${version}";
    sha256 = "sha256-Ouk47S6wYlDDVip9bllgv7+Yg/hNGJQXpcSrb5EN8NA=";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  buildInputs = [
    perl
    libpcap
  ];

  postPatch = ''
    substituteInPlace tools/scan6.c tools/script6 \
      --replace-fail "/etc/ipv6toolkit.conf" "$out/etc/ipv6toolkit.conf"

    substituteInPlace GNUmakefile Makefile \
      --replace-fail "\$(PREFIX)/share/ipv6toolkit/" "$out/share/ipv6toolkit/"
  '';

  postFixup = ''
    for script in script6 messi blackhole6; do
      wrapProgram "$out/bin/$script" \
        --prefix PERL5LIB : "${
          with perlPackages;
          makePerlPath [
            NetIP
            NetDNS
            CryptX509
            ConvertASN1
          ]
        }" \
        --prefix PATH : "$out/bin:${
          (lib.makeBinPath [
            curl
          ])
        }"
    done
  '';

  makeFlags = [
    "PREFIX=/"
    "MANPREFIX=/share"
  ];
  installFlags = [ "DESTDIR=$(out)" ];

  meta = with lib; {
    description = "SI6 Networks' IPv6 Toolkit ";
    homepage = "https://www.si6networks.com/tools/ipv6toolkit";
    license = with licenses; [ gpl3 ];
  };
}
