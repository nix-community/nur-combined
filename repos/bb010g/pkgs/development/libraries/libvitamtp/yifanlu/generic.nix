{ pname ? "libvitamtp-yifanlu", version, src } @ versionArgs:
{ stdenv, buildPackages, fetchFromGitHub
, libiconv, libxml2
# output control
, withDevdoc ? true
, withOpenCma ? true
# options
, enableStaticOpenCma ? false
, enableUsb ? true
, libusb1 ? null
, enableWireless ? true
}:

assert withDevdoc -> buildPackages.doxygen != null;
assert enableUsb -> libusb1 != null;

let
  inherit (stdenv.lib) enableFeature enableFeatureAs optional;
in stdenv.mkDerivation rec {
  inherit pname;
  inherit version;

  src = fetchFromGitHub ({
    owner = "yifanlu";
    repo = "VitaMTP";
    rev = "v${version}";
  } // versionArgs.src);

  outputs = optional withOpenCma "bin"
    ++ [ "out" "dev" ]
    ++ optional withDevdoc "devdoc";
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

  postPatch = ''
    touch config.rpath
  '';

  configureFlags = [
    (enableFeatureAs withOpenCma "opencma"
      (if enableStaticOpenCma then "static" else "dynamic"))
    (enableFeature withDevdoc "doxygen")
    (enableFeature enableUsb "usb-support")
    (enableFeature enableWireless "wireless-support")
  ];

  meta = with stdenv.lib; {
    description = "Library for low-level Vita USB communications";
    longDescription = ''
      libVitaMTP is a library based off of libMTP that does low level USB
      communications with the Vita. It can read and receive MTP commands that
      the Vita sends, which are a proprietary set of commands that is based on
      the MTP open standard.

      OpenCMA is a frontend that allows the user to transfer games, saves, and
      media to and from the PlayStation Vita. It makes use of libVitaMTP to
      communicate with the device and other libraries to interpret the data
      sent and received. OpenCMA is a command line tool that aims to be an
      open source replacement to Sony's official Content Management Assistant.
    '';
    homepage = "https://github.com/yifanlu/VitaMTP";
    license = with licenses; gpl3Plus;
    maintainers = with maintainers; [ bb010g ];
    platforms = with platforms; linux;
  };
}
