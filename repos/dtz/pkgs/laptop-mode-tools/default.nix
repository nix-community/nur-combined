{ stdenv, fetchFromGitHub, coreutils, which, utillinux, gnused, gnugrep, gawk, makeWrapper }:

stdenv.mkDerivation rec {
  name = "laptop-mode-tools-${version}";
  version = "1.72.2";

  src = fetchFromGitHub {
    owner = "rickysarraf";
    repo = "laptop-mode-tools";
    rev = version;
    sha256 = "1pl0rh1bh23ji5r60nvra26ns3z5dfbjj1l9lhzf7hsmpydrgznd";
  };

  nativeBuildInputs = [ makeWrapper ];

  postPatch = ''
    substituteInPlace install.sh \
      --replace DESTDIR/usr DESTDIR
  '';

  installPhase = ''
    MAN_D=/share/man \
    ULIB_D=/lib \
    DESTDIR=$out \
    INIT_D="none" \
    INSTALL=install \
    SYSTEMD=yes \
    ./install.sh
  '';

  preFixup = ''
    substituteInPlace $out/lib/udev/rules.d/99-laptop-mode.rules \
      --replace lmt-udev $out/lib/udev/lmt-udev

    substituteInPlace $out/lib/systemd/system/lmt-poll.service \
      --replace /lib/udev/lmt-udev $out/lib/udev/lmt-udev

    substituteInPlace $out/lib/systemd/system/laptop-mode.service \
      --replace /bin/rm ${coreutils}/bin/rm \
      --replace /usr/sbin/laptop_mode $out/bin/laptop_mode

    sed -i $out/sbin/laptop_mode -e 's/export PATH=.*//'
    substituteInPlace $out/sbin/laptop_mode \
      --replace /sbin/blockdev ${utillinux}/bin/blockdev
    wrapProgram $out/sbin/laptop_mode \
      --prefix PATH : "${stdenv.lib.makeBinPath [ coreutils which utillinux gnused gnugrep gawk ]}"
  '';

  meta = with stdenv.lib; {
    homepage = http://rickysarraf.github.io/laptop-mode-tools;
    description = "Power Savings tool for Linux";
    license = licenses.gpl2;
    maintainers = with maintainers; [ dtzWill ];
  };
}
