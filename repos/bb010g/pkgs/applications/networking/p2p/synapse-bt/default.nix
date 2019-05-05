{ stdenv, buildPackages, rustPlatform, fetchFromGitHub
, openssl, systemd, Security
}:

let
  inherit (stdenv) hostPlatform;
  inherit (stdenv.lib) optional;
in rustPlatform.buildRustPackage rec {
  name = "synapse-bt-unstable-${version}";
  version = "2019-04-06";

  src = fetchFromGitHub {
    owner = "Luminarys";
    repo = "synapse";
    rev = "20072edcc75ab5858a4e90babc493c7aefed91e8";
    sha256 = "1czkshzrbih3277k87rwpyg8ffi6hp646rzva9wdwwwy9m1ilagb";
  };

  cargoSha256 = "0hfhayyc86lr3ah5nagnbn435qplfjvcrnambr9sia8y3i9jnq9g";

  nativeBuildInputs = [ buildPackages.pkgconfig ];
  buildInputs = [
    openssl
  ] ++ optional hostPlatform.isLinux
    systemd
  ++ optional hostPlatform.isDarwin
    Security;

  cargoBuildFlags = [ "--all" ];

  postInstall = stdenv.lib.optionalString hostPlatform.isLinux ''
    install -Dm644 ${./synapse-bt.service} \
      "''${!outputBin}/etc/systemd/user/synapse-bt.service"

  '' + ''
    # fix buildRustPackage installPhase locations
    moveToOutput bin "''${!outputBin}"
    moveToOutput lib "''${!outputLib}"
  '';

  meta = with stdenv.lib; {
    description = "Flexible and fast BitTorrent daemon";
    homepage = https://synapse-bt.org/;
    license = with licenses; isc;
    maintainers = with maintainers; [ dywedir ];
    platforms = with platforms; all;
  };
}
