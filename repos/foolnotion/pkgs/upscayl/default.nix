{appimageTools, fetchurl, lib}:

let
  pname = "upscayl";
  version = "2.5.1";
  src = fetchurl {
    url = "https://github.com/upscayl/upscayl/releases/download/v${version}/upscayl-${version}-linux.AppImage";
    sha256 = "sha256-mAMq7I7oH9BBJeLUT4mGxlh7vPNPwa6JeQUHnGoCgdc=";
  };
  appimageContents = appimageTools.extractType2 { inherit pname version src; };
in
appimageTools.wrapType2 rec {
  inherit pname version src;

  name = pname;

  extraInstallCommands = ''
    mkdir -p $out/share/{applications,pixmaps}

    cp ${appimageContents}/${pname}.desktop $out/share/applications/${pname}.desktop
    cp ${appimageContents}/${pname}.png $out/share/pixmaps/${pname}.png

    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace 'Exec=AppRun --no-sandbox %U' 'Exec=${pname}'
  '';

  extraPkgs = pkgs: with pkgs; [ vulkan-headers vulkan-loader ];

  meta = with lib; {
    description = "Free and Open Source AI Image Upscaler";
    homepage = "https://upscayl.github.io/";
    maintainers = with maintainers; [  ];
    platforms = platforms.linux;
  };
}
