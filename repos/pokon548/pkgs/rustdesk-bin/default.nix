{ appimageTools, lib, fetchurl, makeWrapper, libsecret }:

let
  pname = "rustdesk-bin";
  version = "1.2.2";
  name = "Rustdesk-${version}";

  src = lib.warn
    "${pname} from pokon548's NUR is deprecated and will be removed from NUR repo soon. Migrate by changing nur.repos.pokon548.rustdesk-bin to pkgs.rustdesk"
    fetchurl {
      url =
        "https://github.com/rustdesk/rustdesk/releases/download/${version}/rustdesk-${version}-x86_64.AppImage";
      sha256 = "sha256-i55J1RsCZw7p/Ibd4lLLQq/DpFQHPeukwsvBC8AYPok=";
    };

  appimageContents = appimageTools.extract { inherit name src; };

in appimageTools.wrapType2 {
  inherit version name src;

  extraInstallCommands = ''
    mv $out/bin/${name} $out/bin/${pname}
    install -m 444 -D ${appimageContents}/rustdesk.desktop -t $out/share/applications
    cp -r ${appimageContents}/usr/share/icons $out/share
  '';

  passthru.version = version;

  extraPkgs = pkgs: with pkgs; [ libsecret libappindicator-gtk3 ];

  meta = with lib; {
    homepage = "https://rustdesk.com";
    description =
      "An open-source remote desktop, and alternative to TeamViewer.";
    platforms = [ "x86_64-linux" ];
    license = licenses.agpl3;
  };
}
