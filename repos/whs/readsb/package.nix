{
  lib, stdenv, pkgs,
  git, pkg-config, libusb1, ncurses, zlib, zstd, libiio, libad9361, librtlsdr, hackrf, soapysdr,
  
  useHistory ? true,
  useRtlsdr ? true,
  usePlutosdr ? true,
  useSoapysdr ? true,
  useBiastee ? true,
  useHackrf ? true,
}:
let
  # When updating version, make sure upstream do not edit Makefile or files in debian/
  version = "3.14.1620";
  sha256 = "sha256-SiY18ZGdBeFkaeucvDgd2BdMhSPFoWLORjEnHPCx5N8=";
in stdenv.mkDerivation {
  pname = "readsb";
  inherit version;
  src = pkgs.fetchFromGitHub {
    owner = "wiedehopf";
    repo = "readsb";
    rev = "v${version}";
    inherit sha256;
  };

  outputs = [ "out" "man" ];

  patches = [
    # Patch the Makefile to use READSB_VERSION instead of calling git
    ./readsb-make.patch
  ];
  
  makeFlags = [
    "READSB_VERSION=${version}-nix-${sha256}"
  ]
    ++ lib.optionals useHistory [ "HISTORY=yes" ]
    ++ lib.optionals useHackrf [ "HACKRF=yes" ]
    ++ lib.optionals usePlutosdr [ "PLUTOSDR=yes" ]
    ++ lib.optionals useSoapysdr [ "SOAPYSDR=yes" ]
    ++ lib.optionals useBiastee [ "HAVE_BIASTEE=yes" ]
    ++ lib.optionals useRtlsdr [ "RTLSDR=yes" "AIRCRAFT_HASH_BITS=15" ]
    ++ lib.optionals stdenv.hostPlatform.isAarch32 [ "CPPFLAGS=-DSC16Q11_TABLE_BITS=8" ];
  
  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ libusb1 ncurses zlib zstd ]
    ++ lib.optionals usePlutosdr [ libiio libad9361 ]
    ++ lib.optionals useHackrf [ hackrf ]
    ++ lib.optionals useSoapysdr [ soapysdr ]
    ++ lib.optionals useRtlsdr [ librtlsdr ];
  propagatedBuildInputs = lib.optionals useRtlsdr [ librtlsdr ];

  installPhase = ''
    mkdir -p $out/bin
    cp -a readsb $out/bin/readsb
    cp -a viewadsb $out/bin/viewadsb

    mkdir -p $man/share/man/man1
    cp debian/*.1 $man/share/man/man1/

    mkdir -p $man/share/doc/readsb/
    cp debian/README.* $man/share/doc/readsb/
  '';

  # https://github.com/NixOS/nixpkgs/issues/40797
  NIX_CFLAGS_LINK = "-lgcc_s";
  
  meta = {
    description = "Readsb is a Mode-S/ADSB/TIS decoder for RTLSDR, BladeRF, Modes-Beast and GNS5894 devices";
    homepage = "https://github.com/wiedehopf/readsb";
    license = lib.licenses.gpl3Plus;
    mainProgram = "readsb";
    platforms = lib.platforms.linux;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
  };
}
