{ appimageTools, lib, fetchurl, makeWrapper, libsecret }:

let
  pname = "rustdesk-bin";
  version = "1.2.3";
  name = "Rustdesk-${version}";

  src = lib.warn
    "${pname} from pokon548's NUR is deprecated and will be removed from NUR repo soon. Migrate by changing nur.repos.pokon548.rustdesk-bin to pkgs.rustdesk"
    fetchurl {
      url =
        "https://github.com/rustdesk/rustdesk/releases/download/nightly/rustdesk-${version}-x86_64.AppImage";
      sha256 = "sha256-FYNzbCu9s6A79zPxM45hjPjjIm9leisNrjV3oUo4iz4=";
    };

  appimageContents = appimageTools.extract { inherit name src; };

in appimageTools.wrapType2 {
  inherit version name src;

  extraInstallCommands = ''
    mkdir -p $out/bin $out/share/${pname} $out/share/applications $out/share/icons/hicolor/256x256
    mv $out/bin/${name} $out/bin/${pname}
    cp -a ${appimageContents}/rustdesk.desktop $out/share/applications/${pname}.desktop
    cp -a ${appimageContents}/usr/share/icons/hicolor/256x256/apps $out/share/icons/hicolor/256x256
    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace 'Exec=usr/lib/rustdesk/rustdesk' 'Exec=${pname}'
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
