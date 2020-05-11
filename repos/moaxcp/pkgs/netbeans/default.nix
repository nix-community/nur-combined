{ stdenv, releaseTools, fetchzip, jdk, ant, makeDesktopItem, makeWrapper,
  which, unzip, libicns, imagemagick, perl, python
}:

let
  pname = "netbeans";
  version = "11.3";
  desktopItem = makeDesktopItem {
    name = "netbeans";
    exec = "netbeans";
    comment = "Integrated Development Environment";
    desktopName = "Netbeans IDE";
    genericName = "Integrated Development Environment";
    categories = "Application;Development;";
    icon = "netbeans";
  };
in releaseTools.antBuild rec {
  inherit pname version;
  name = "${pname}-${version}";
  src = fetchzip {
    url = "mirror://apache/netbeans/netbeans/${version}/netbeans-${version}-source.zip";
    sha512 = "2pxv82l0d3xpv6j44h9bxgs5jjmvqbyyfg38dz8k55vvnypbsvcz8agfvpi65dm9czsgvsf9kdccz0lvpf72vgzc14haz0nlf1bl7pl";
    stripRoot = false;
  };

  buildInputs = [ makeWrapper perl python unzip libicns imagemagick ];

  antProperties = [
    {"name" = "ext.binaries.downloaded"; "value" = "true";}
  ];

  buildCommand = ''
    # Unpack and perform some path patching.
    unzip $src
    patchShebangs .

    # Copy to installation directory and create a wrapper capable of starting it.
    mkdir $out
    cp -a netbeans $out
    makeWrapper $out/netbeans/bin/netbeans $out/bin/netbeans \
      --prefix PATH : ${stdenv.lib.makeBinPath [ jdk which ]} \
      --prefix JAVA_HOME : ${jdk.home} \
      --add-flags "--jdkhome ${jdk.home}"

    # Extract pngs from the Apple icon image and create
    # the missing ones from the 1024x1024 image.
    icns2png --extract $out/netbeans/nb/netbeans.icns
    for size in 16 24 32 48 64 128 256 512 1024; do
      mkdir -pv $out/share/icons/hicolor/"$size"x"$size"/apps
      if [ -e netbeans_"$size"x"$size"x32.png ]
      then
        mv netbeans_"$size"x"$size"x32.png $out/share/icons/hicolor/"$size"x"$size"/apps/netbeans.png
      else
        convert -resize "$size"x"$size" netbeans_1024x1024x32.png $out/share/icons/hicolor/"$size"x"$size"/apps/netbeans.png
      fi
    done;
    
    # Create desktop item, so we can pick it from the KDE/GNOME menu
    mkdir -pv $out/share/applications
    ln -s ${desktopItem}/share/applications/* $out/share/applications
  '';

  meta = {
    broken = true;
    description = "An integrated development environment for Java, C, C++ and PHP";
    homepage = "https://netbeans.org/";
    license = stdenv.lib.licenses.asl20;
    maintainers = with stdenv.lib.maintainers; [ moaxcp sander rszibele ];
    platforms = stdenv.lib.platforms.unix;
  };
  
}
