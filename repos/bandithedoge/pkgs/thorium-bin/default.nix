{
  pkgs,
  sources,
  ...
}: let
  appimageContents = pkgs.appimageTools.extract {
    inherit (sources.thorium-bin) pname version src;
  };
in
  pkgs.appimageTools.wrapType2 {
    inherit (sources.thorium-bin) version src;
    pname = "thorium";

    extraInstallCommands = ''
      cp -r ${appimageContents}/usr/share $out/share
      chmod +w $out/share
      mkdir -p $out/share/applications
      cp ${appimageContents}/thorium-browser.desktop $out/share/applications
    '';

    meta = with pkgs.lib; {
      description = "Chromium fork named after radioactive element No. 90";
      homepage = "https://thorium.rocks";
      license = licenses.bsd3;
      platforms = ["x86_64-linux"];
    };
  }
