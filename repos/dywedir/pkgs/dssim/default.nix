{ stdenv, fetchCrate, rustPlatform }:

rustPlatform.buildRustPackage rec {
  name = "dssim-${version}";
  version = "2.9.9";

  src = fetchCrate {
    crateName = "dssim";
    version = version;
    sha256 = "1z59d802ga839qhh99c1n8j4z6ggy9yly9cs0gzs9k3m6l88ahpc";
  };

  cargoSha256 = "0qbw8xbscfvxrwjxzfs871zgaxdl13ifclx3i4vplh7rm0fx98yv";

  cargoPatches = [ ./cargo-lock.patch ];

  meta = with stdenv.lib; {
    description = "Image similarity comparison simulating human perception";
    longDescription = ''
      This tool computes (dis)similarity between two or more PNG images using
      an algorithm approximating human vision.

      Comparison is done using the SSIM algorithm at multiple weighed
      resolutions.
    '';
    homepage = "https://kornel.ski/dssim";
    license = with licenses; [ agpl3 ];
    maintainers = with maintainers; [ dywedir ];
    platforms = platforms.all;
  };
}
