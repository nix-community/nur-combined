{ lib
, fetchFromSourcehut
, buildGoModule
}:

buildGoModule rec {
  pname = "wlhax";
  version = "unstable-2024-03-23";

  src = fetchFromSourcehut {
    owner = "~kennylevinsen";
    repo = pname;
    rev = "10b42941847f11a43dceaf8bf449301056c71f3b";
    hash = "sha256-A9oohPiXKP4mFN6CnWsaRalQuDc0dEFohHNUgm5NjjI=";
  };

  vendorHash = "sha256-1zAKVg+l1frdE+PYgc0sjjQ+v/OJa9b7leikPwbDl3o=";
  
  meta = with lib; {
    description = "Wayland proxy that monitors and displays various application state";
    homepage = "https://git.sr.ht/~kennylevinsen/wlhax";
    license = licenses.gpl3Plus;
  };
}

