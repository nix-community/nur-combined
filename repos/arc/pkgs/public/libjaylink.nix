{ stdenv, fetchFromRepoOrCz, autoreconfHook, pkg-config, libusb1 }: stdenv.mkDerivation {
  pname = "libjaylink";
  version = "2021-03-14";
  nativeBuildInputs = [ pkg-config autoreconfHook ];
  buildInputs = [ libusb1 ];

  src = fetchFromRepoOrCz {
    #url = "git://git.zapb.de/libjaylink.git"; # appears to be down?
    repo = "libjaylink";
    rev = "6654e2be5e7a6ae3eb9d66174f965a0db19d1172";
    sha256 = "0s8x67qsl86lalc765rrwa9xr9q0qcj8ss01f8raka4rdv1iv1cp";
  };
}
