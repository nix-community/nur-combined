# https://github.com/NixOS/nixpkgs/pull/98479
# TODO: delete when merged

{ stdenv
, fetchgit
, meson
, ninja
, pkg-config
, wrapGAppsHook
, gtk3
, gnome3
, tiffSupport ? true
, libraw
, jpgSupport ? true
, imagemagick
, exiftool
}:

assert jpgSupport -> tiffSupport;

let
  inherit (stdenv.lib) makeBinPath optional optionals optionalString;
  runtimePath = makeBinPath (
    optional tiffSupport libraw
    ++ optionals jpgSupport [ imagemagick exiftool ]
  );
in
stdenv.mkDerivation rec {
  pname = "megapixels";
  version = "0.13.2";

  src = fetchgit {
    url = "https://git.sr.ht/~martijnbraam/megapixels";
    rev = version;
    sha256 = "1dqilx11c4vx793hsk3c6jfsfv2qlzsbkx3m3hmgjlhdd41v5vf3";
  };

  nativeBuildInputs = [ meson ninja pkg-config wrapGAppsHook ];

  buildInputs = [ gtk3 gnome3.adwaita-icon-theme ]
  ++ optional tiffSupport libraw
  ++ optional jpgSupport imagemagick;

  preFixup = optionalString (tiffSupport || jpgSupport) ''
    gappsWrapperArgs+=(
      --prefix PATH : ${runtimePath}
    )
  '';

  meta = with stdenv.lib; {
    description = "GTK3 camera application using raw v4l2 and media-requests";
    homepage = "https://sr.ht/~martijnbraam/Megapixels";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ OPNA2608 ];
    platforms = platforms.linux;
  };
}
