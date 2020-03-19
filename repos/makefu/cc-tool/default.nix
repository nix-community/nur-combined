{ stdenv, lib, pkgs, autoreconfHook ,libtool, fetchFromGitHub, boost, libusb1,
pkgconfig,file }:
stdenv.mkDerivation rec {
  pname = "cc-tool";
  version = "407fd7e";
  name = "${pname}-${version}";

  src = fetchFromGitHub {
    owner = "dashesy";
    repo = "cc-tool";
    rev = version;
    sha256 = "1q7zqib4rn5l8clk2hj7078rfyrjdwxzpyg4r10is31lq22zhxqj";
  };

  buildInputs = [ boost libtool libusb1 pkgconfig autoreconfHook ];

  preConfigure = ''
    substituteInPlace configure \
        --replace /usr/bin/file ${file}/bin/file

  '';

  postInstall = ''
    install -m755 -D ./udev/90-cc-debugger.rules $out/etc/udev/rules.d/90-cc-debugger.rules
  '';

  meta = {
    homepage = https://github.com/AKuHAK/hdl-dump ;
    description = "copy isos to psx hdd";
    license = lib.licenses.gpl2;
  };
}
