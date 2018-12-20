{ stdenv, fetchFromGitHub, rustPlatform
, libX11, libXrandr
, pkgconfig, python3 }:

rustPlatform.buildRustPackage rec {
  name = "hacksaw-${version}";
  version = "0.0.1+${builtins.substring 0 7 src.rev}";

  src = fetchFromGitHub {
    owner = "neXromancers";
    repo = "hacksaw";
    rev = "fcb430fdabe80576858e8c28919e2f8c533379e3";
    sha256 = "1kgcw0669221dz8l70aa89xbw3cd8yjg708pbx3bhazgq0s24v51";
  };

  cargoSha256 = "0f8nklg5yjcs04kn95ccyl9gy5figzv0lpix2zzk3q0d9imzzcdg";

  nativeBuildInputs = [ pkgconfig python3 ];
  buildInputs = [ libX11 libXrandr ];

  meta = with stdenv.lib; {
    description = "Lets you select areas of your screen (on X11)";
    homepage = https://github.com/neXromancers/hacksaw;
    license = with licenses; [ mpl20 ];
    maintainers = with maintainers; [ bb010g ];
    platforms = platforms.all;
  };
}

