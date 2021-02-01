{appimageTools, fetchurl, gsettings-desktop-schemas, gtk3}:
appimageTools.wrapType2 { # or wrapType1
  name = "wowup"; 
  src = fetchurl { 
    url = "https://github.com/WowUp/WowUp/releases/download/v2.0.2/WowUp-2.0.2.AppImage";
    sha256 =  "1b9662w1hyzzlabi7l27ixnwzyxzdzv5bfdrcvacsilhp9dynnn2";
  };
  profile = ''
    export XDG_DATA_DIRS=${gsettings-desktop-schemas}/share/gsettings-schemas/${gsettings-desktop-schemas.name}:${gtk3}/share/gsettings-schemas/${gtk3.name}:$XDG_DATA_DIRS
  '';
}
