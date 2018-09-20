{ lib, fetchFromGitHub, stdenv, ncurses, autoreconfHook, pkgconfig,
IOKit, python }:

stdenv.mkDerivation rec {
  name = "htop-${version}";
  version = "3.0.0beta5";

  src = fetchFromGitHub {
    owner = "hishamhm";
    repo = "htop";
    rev = version;
    sha256 = "1d17c1rjn9ykr4akj3hhkb2bsl5hzlygk3x4sdmq8mqbsnw57jin";
  };

  nativeBuildInputs = [ python autoreconfHook pkgconfig ];
  buildInputs =
    [ ncurses ] ++
    lib.optionals stdenv.isDarwin [ IOKit ];

  hardeningDisable = [ "format" ];

  prePatch = ''
    patchShebangs scripts/MakeHeader.py
  '';

  configureFlags = [
    "--enable-unicode"
    "--enable-cgroup"
    "--enable-taskstats"
    "--enable-linux-affinity"
  ];

  meta = with stdenv.lib; {
    description = "An interactive process viewer for Linux";
    homepage = https://hisham.hm/htop/;
    license = licenses.gpl2Plus;
    platforms = with platforms; linux ++ freebsd ++ openbsd ++ darwin;
    maintainers = with maintainers; [ /* rob relrod nckx */ dtzWill ];
  };
}
