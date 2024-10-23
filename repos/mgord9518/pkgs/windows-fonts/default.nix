{ stdenv, lib, fetchurl, p7zip }:

# TODO: support bitmap (.fon) fonts
stdenv.mkDerivation rec {
  pname = "windows-fonts";
  version = "1.0.0";

  buildInputs = [ p7zip ];

  src = fetchurl {
    url = "https://api.gravesoft.dev/msdl/proxy?product_id=3113&sku_id=18480";
    sha256 = "sha256-tWuRG/GKLOrrOQTYfnx3C9+S0wmVmdYawkl7kb8ZCxE=";
    downloadToTemp = true;

    # MS sends a re-direction page, so we have to extract the URL and follow that
    postFetch = ''
      echo "------ DOWNLOADING WINDOWS ISO FOR FONT EXTRACTION ------"
      echo "This could take a while..."
      real_url=$(cat "$downloadedFile" | grep -o '<a href="[^"]*">' | cut -d'"' -f2)
      curl -o "$out" "$real_url"
    '';
  };

  dontBuild = true;

  # TODO: Can we read the WIM file from the ISO without extracting? The AUR
  # PKGBUILD uses kernel mounting, but unfortunately that requires root and
  # I haven't found an ISO FUSE FS that supports UDF
  unpackPhase = ''
    mkdir -p "$out/share/fonts/truetype"

    7z e "$src" "sources/install.wim" -tudf
  '';

  installPhase = ''
    7z e "install.wim" "1/Windows/Fonts/*.tt?" -o"$out/share/fonts/truetype"

    rm "install.wim"
  '';

  meta = {
    description = "MS Windows font package";
    homepage = "http://www.microsoft.com";
    license = lib.licenses.unfree;

    # Set a non-zero priority to allow easy overriding of the
    # fontconfig configuration files.
    priority = 5;
  };
}
