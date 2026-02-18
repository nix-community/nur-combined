{
  lib,
  stdenv,
  meson,
  ninja,
  pkg-config,
  boost,
  howard-hinnant-date,
  nix,
  nlohmann_json,
  fetchpijul,
}:

stdenv.mkDerivation {
  pname = "nix-plugin-pijul";
  version = "0.1.6";

  src = fetchpijul {
    url = "https://nest.pijul.com/DzmingLi/nix-plugin-pijul";
    hash = "sha256-6CgGJ34UXM81ZHVfLWRjVpMmGRDfaGbBytxDhLw7aY8="; # fill after pushing to nest
  };

  nativeBuildInputs = [meson ninja pkg-config];
  buildInputs = [boost howard-hinnant-date nix nlohmann_json];

  meta = with lib; {
    description = "Nix plugin adding Pijul fetcher support";
    homepage = "https://nest.pijul.com/DzmingLi/nix-plugin-pijul";
    license = licenses.lgpl3Only;
  };
}
