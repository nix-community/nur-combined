{ rustPlatform
, fetchFromGitLab
, glib
, gtk4
, json-glib
, libadwaita
, libsoup_3
, openssl
, pkg-config
, sqlite
, webkitgtk_6_0
, wrapGAppsHook4
}:
rustPlatform.buildRustPackage rec {
  pname = "hackgregator";
  # 0.5.0 uses libhandy + webkitgtk4; master uses libadwaita + webkitgtk6
  version = "0.5.0-unstable-2023-12-05";
  src = fetchFromGitLab {
    owner = "gunibert";
    repo = "hackgregator";
    # rev = version;
    # hash = "sha256-N7pSy4OP5dz8tSjif2d856z557PZjGXWpM+1e30K5pU=";
    rev = "594bdcdc3919c7216d611ddbbc77ab4d0c1f4f2b";
    hash = "sha256-RE0x4YWquWAcQzxGk9zdNjEp1pijrBtjV1EMBu9c5cs=";
  };
  # cargoHash = "sha256-WWrf3KMBeBCopOvPCTJSecdgOXvxVp8d3/lzvcNE2bk=";
  cargoHash = "sha256-OPlYFUhAFRHqXS2vad0QYlhcwyyxdxi1kjpTxVlgyxs=";

  nativeBuildInputs = [
    glib  # for glib_build_tools
    pkg-config
    wrapGAppsHook4
  ];
  buildInputs = [
    glib
    gtk4
    json-glib
    libadwaita
    libsoup_3
    openssl
    sqlite
    webkitgtk_6_0
  ];

  doCheck = false;  # use of undeclared crate or module `mockito`
}
