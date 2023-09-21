{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
}:

rustPlatform.buildRustPackage rec {
  pname = "aw-watcher-window-wayland";
  version = "master";

  src = fetchFromGitHub {
    owner = "ActivityWatch";
    repo = pname;
    rev = "6108ad3df8e157965a43566fa35cdaf144b1c51b";
    sha256 = "sha256-xl9+k6xJp5/t1QPOYfnBLyYprhhrzjzByDKkT3dtVVQ=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "aw-client-rust-0.1.0" = "sha256-9tlVesnBeTlazKE2UAq6dzivjo42DT7p7XMuWXHHlnU=";
    };
  };

  cargoHash = "sha256-MFuQSCiGzCthwOPweVF3elmCnUQmxffiAcSTmNrp3mt=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ openssl ];

  strictDeps = true;

  meta = with lib; {
    description = "WIP window and afk watcher for wayland";
    homepage = "https://github.com/ActivityWatch/aw-watcher-window-wayland";
    license = licenses.mpl20;
    maintainers = [ maintainers.polykernel ];
    platforms = platforms.linux;
  };
}
