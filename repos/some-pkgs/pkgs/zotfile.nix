{ lib
, stdenv
, fetchFromGitHub
, jdk
, zip
}:

stdenv.mkDerivation rec {
  pname = "zotfile";
  version = "5.1.2";

  src = fetchFromGitHub {
    owner = "jlegewie";
    repo = "zotfile";
    rev = "v${version}";
    hash = "sha256-Yrd/lQ0OFGMl5NnfeM8pu3d09UIN6buQ9sPIBqckpEg=";
  };

  nativeBuildInputs = [
    zip
  ];

  dontBuild = true;
  installPhase =
    let
      firefoxAppId = "ec8030f7-c20a-464f-9b0e-13a3a9e97384";
    in
    ''
      dst="$out/share/mozilla/extensions/{${firefoxAppId}}"
      mkdir -p "$dst"
      (cd "$src" && zip -r "$dst/nix@zotfile.xpi" ".")
    '';
  # install -v -m644 "zotfile-${version}-fx.xpi" "$dst/nix@zotfile.xpi"

  meta = with lib; {
    description = "Zotero plugin to manage your attachments: automatically
    rename, move, and attach PDFs (or other files) to Zotero items, sync PDFs
    from your Zotero library to your (mobile) PDF reader (e.g. an iPad, Android
    tablet, etc.), and extract PDF annotations";
    homepage = "https://github.com/jlegewie/zotfile";
    license = with licenses; [ ];
    maintainers = with maintainers; [ ];
  };
}
