{ lib, buildGoModule, fetchFromSourcehut }:

buildGoModule rec {
  pname = "gssg";
  version = "2022-03-31";

  src = fetchFromSourcehut {
    owner = "~gsthnz";
    repo = "gssg";
    rev = "a842c013b9fa044b720b32ee015fedcde3f24ab1";
    hash = "sha256-OwS6nUQ8AUbzm8ibckbvyfjdxT+KYyuDzcJAR95wUoU=";
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
