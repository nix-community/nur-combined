{ lib, stdenv, buildGoModule, callPackage, makeWrapper, gnome3, xdg-utils }:

let
  common = callPackage ./common.nix {};
in buildGoModule rec {
  pname = "awl-tray";

  inherit (common) version src;

  buildInputs = [ makeWrapper ];

  preBuild = ''
    cp -r ${common.awl_flutter} static
    cd cmd/awl-tray
  '';

  postInstall = ''
    wrapProgram $out/bin/awl-tray \
      --prefix PATH ":" "${lib.makeBinPath [ xdg-utils ]}"
  '';

  propagatedUserEnvPkgs = [ gnome3.zenity ];

  proxyVendor = true;
  vendorHash = "sha256-jQwHWfZcOiXHFthtCbnI4ri03kyGSgkzaVVgbXWMaHw=";

  meta = with lib; {
    description = "Securely connect your devices into a private network";
    homepage = src.meta.homepage;
    license = licenses.mpl20;
    maintainers = with maintainers; [ ];
    platforms = platforms.linux;
  };
}
