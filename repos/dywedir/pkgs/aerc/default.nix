{ stdenv, fetchgit, buildGoModule, pkgconfig, libvterm-neovim }:

buildGoModule rec {
  pname = "aerc";
  version = "unstable-2019-05-24";

  src = fetchgit {
    url = "https://git.sr.ht/~sircmpwn/aerc";
    rev = "c4c8648cc716d40f5f6558b5f2bf375d8f9a36d9";
    sha256 = "0s8ldq1pkspd16l33gvfh824kcw6n18d5bz7nsbd7xghkyq703rd";
  };

  modSha256 = "1s1sipj185wh9q0d748gwn1nghss427y4d0xvg5lx4270anmnkna";

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ libvterm-neovim ];

  meta = with stdenv.lib; {
    description = "Work in progress email client for your terminal";
    homepage = "https://git.sr.ht/~sircmpwn/aerc";
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = with maintainers; [ dywedir ];
  };
}
