{ lib, stdenv, buildGoModule, callPackage, makeWrapper, gnome3, libappindicator }:

let
  common = callPackage ./common.nix {};
in buildGoModule rec {
  pname = "awl-tray";

  inherit (common) version src;

  buildInputs = [ makeWrapper ];

  preBuild = ''
    touch embeds/wintun.dll
    cp -r ${common.awl_flutter} static
    cd cmd/awl-tray
  '';

  postInstall = ''
    wrapProgram $out/bin/awl-tray \
      --prefix PATH ":" "${lib.makeBinPath [ gnome3.zenity ]}" \
      --prefix LD_LIBRARY_PATH ":" "${lib.makeLibraryPath [ libappindicator ]}"
  '';

  ldflags = [
    "-X github.com/anywherelan/awl/config.Version=v${version}"
  ];

  proxyVendor = true;
  vendorHash = "sha256-7nmPchoKz/ARq6QRBFFJVnnxyEopHvBf6xbmTY/b67Y=";

  meta = with lib; {
    description = "Securely connect your devices into a private network";
    homepage = src.meta.homepage;
    license = licenses.mpl20;
    maintainers = with maintainers; [ ];
    platforms = platforms.linux;
  };
}
