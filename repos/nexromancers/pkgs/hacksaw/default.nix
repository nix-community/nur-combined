{ stdenv, rustPlatform, fetchFromGitHub
, libX11, libXrandr
, pkgconfig, python3
}:

rustPlatform.buildRustPackage rec {
  name = "hacksaw-${version}";
  version = "0.0.1+${builtins.substring 0 7 src.rev}";

  src = fetchFromGitHub {
    owner = "neXromancers";
    repo = "hacksaw";
    rev = "742de431caa5c0500fb064578a68900176783be6";
    sha256 = "1gf7p11df3xz33z31xjpshv3qn5smw7n8qk8d6ha594cqz68cxvi";
  };

  cargoSha256 = "0f8nklg5yjcs04kn95ccyl9gy5figzv0lpix2zzk3q0d9imzzcdg";

  nativeBuildInputs = [ pkgconfig python3 ];
  buildInputs = [ libX11 libXrandr ];

  meta = with stdenv.lib; {
    description = "Lets you select areas of your screen (on X11)";
    homepage = https://github.com/neXromancers/hacksaw;
    license = with licenses; mpl20;
    maintainers = with maintainers; [ bb010g ];
    platforms = platforms.unix;
  };
}

