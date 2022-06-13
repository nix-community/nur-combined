{ lib, fetchFromGitHub, rustPlatform, pkgconfig, dbus }:

rustPlatform.buildRustPackage rec {
  nativeBuildInputs = [
    pkgconfig
  ];

  buildInputs = [
    dbus
  ];

  pname = "draconis";
  version = "2.4.8";

  src = fetchFromGitHub {
    owner = "marsupialgutz";
    repo = "draconis";
    rev = "b2e87e5fa611ff8010bf39383e1b57f61dc082f5";
    sha256 = "16wgx56xlpznal2iq99hn8imf27mlj440470h4chfs4fd5kj7zzy";
  };

  cargoSha256 = "B5dHvn2IXDR3vdTqdOAULdAVKiCPJgKNBrPuRp/47hg=";

  meta = with lib; {
    description = "🪐 An out-of-this-world greeter for your terminal";
    homepage = "https://github.com/marsupialgutz/draconis";
    platforms = platforms.linux;
  };
}
