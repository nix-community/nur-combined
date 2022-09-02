{ lib, buildGoModule, fetchFromSourcehut }:

buildGoModule rec {
  pname = "gssg";
  version = "2020-12-08";

  src = fetchFromSourcehut {
    owner = "~gsthnz";
    repo = "gssg";
    rev = "747b6b41fbe93f0b408a58c8e6a1f11c7945c819";
    hash = "sha256-yMWj3wHSq4KZ2ezECBpCXhgqlpIm2zSe0sZP8OxNLIw=";
  };

  vendorHash = "sha256-NxfZbwKo8SY0XfWivQ42cNqIbJQ1EBsxPFr70ZU9G6E=";

  meta = with lib; {
    description = "A gemini static site generator";
    inherit (src.meta) homepage;
    license = licenses.gpl3Only;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
