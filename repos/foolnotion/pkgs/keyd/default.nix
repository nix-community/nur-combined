{ lib, fetchFromGitHub, stdenv }:

stdenv.mkDerivation rec {
  pname = "keyd";
  version = "2.3.1-rc";

  src = fetchFromGitHub {
    owner = "rvaiya";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-mb42IazLFOWYH0fDnNcMOpsq9X0xjWDfWyjszRGbwU8=";
  };

  makeFlags = [ "DESTDIR=${placeholder "out"}" "PREFIX=" ];

  meta = with lib; {
    homepage = "https://github.com/rvaiya/keyd";
    description = "A key remapping daemon for linux";
    longDescription = ''
      Keyd has several unique features many of which are traditionally
      only found in custom keyboard firmware like QMK as well as some
      which are unique to keyd.
      It expects a configuration file at /etc/keyd/default.conf. For
      more details check out the homepage.
    '';
    license = licenses.mit;
    maintainers = with maintainers; [ dit7ya ];
    platforms = platforms.linux;
  };
}
