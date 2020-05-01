{ stdenv, buildPackages, fetchFromGitHub
, libiconv, libxml2
# output control
, withDevdoc ? true
# options
, enableUsb ? true
, libusb1 ? null
, enableWireless ? true
}:

assert withDevdoc -> buildPackages.doxygen != null;
assert enableUsb -> libusb1 != null;

let
  inherit (stdenv.lib) enableFeature enableFeatureAs optional;
in stdenv.mkDerivation rec {
  pname = "libvitamtp";
  version = "2.5.9";

  src = fetchFromGitHub {
    owner = "codestation";
    repo = "vitamtp";
    rev = "v${version}";
    sha256 = "09c9f7gqpyicfpnhrfb4r67s2hci6hh31bzmqlpds4fywv5mzaf8";
  };

  outputs = [ "out" "dev" ] ++ optional withDevdoc "devdoc";
  outputLib = "out";
  outputDoc = "devdoc";

  nativeBuildInputs = [
    buildPackages.autoconf
    buildPackages.automake
    buildPackages.autoreconfHook
    buildPackages.pkgconfig
  ] ++ optional withDevdoc
    buildPackages.doxygen;
  buildInputs = [
    libiconv
    libxml2
  ] ++ optional enableUsb
    libusb1;

  configureFlags = [
    (enableFeature withDevdoc "doxygen")
    (enableFeature enableUsb "usb-support")
    (enableFeature enableWireless "wireless-support")
  ];

  meta = with stdenv.lib; {
    description = "Library to interact with Vita's USB MTP protocol";
    longDescription = ''
      libvitamtp is a library based off of libMTP that does low level USB
      communications with the Vita. It can read and receive MTP commands that
      the Vita sends, which are a proprietary set of commands that is based on
      the MTP open standard.
    '';
    homepage = https://github.com/codestation/libvitamtp;
    license = with licenses; gpl3Plus;
    maintainers = with maintainers; [ bb010g ];
    platforms = with platforms; linux;
  };
}
