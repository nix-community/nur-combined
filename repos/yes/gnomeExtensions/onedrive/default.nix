{
  pkgs,
  lib,
  stdenv,
  fetchzip,
  jq,
  rp ? "",
  onedriveConfDir ? "onedrive",
}:

let 
  uuid = "onedrive@diegobazzanella.com";
  version = "unstable-2022-03-28";
  commit = "aa19f27fe8117bdc9e630d59676eb7fc20b5b5cc";
in

stdenv.mkDerivation rec {
  inherit version;
  pname = "gnome-shell-extension-onedrive";

  src = fetchzip {
    url = "${rp}https://github.com/Silvanoc/oneDrive/archive/${commit}.zip";
    sha256 = "sha256-jMrbFj/kEn2HRGKvIk/xAOfykvezRfAoiB9VwfVPcZw=";
  };

  nativeBuildInputs = [ jq ];

  postPatch = ''
    for cmd in status is-active stop start; do
      substituteInPlace extension.js --replace "$cmd onedrive" "$cmd onedrive@${onedriveConfDir}"
    done
    metadata=$(jq '."shell-version"=["3.38","40","41","42"] | .version="${version}"' metadata.json)
    echo $metadata > metadata.json
  '';

  installPhase = ''
    mkdir -p $out/share/gnome-shell/extensions/
    cp -r -T . $out/share/gnome-shell/extensions/${uuid}
  '';

  passthru = {
    extensionUuid = uuid;
    extensionPortalSlug = "onedrive";
  };

  meta = with lib; {
    description = "A frontend for the unofficial abraunegg onedrive client";
    license = licenses.gpl2;
    homepage = "https://github.com/Silvanoc/oneDrive";
  };
}