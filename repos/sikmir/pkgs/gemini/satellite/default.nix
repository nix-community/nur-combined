{ lib, buildGoModule, fetchFromSourcehut }:

buildGoModule rec {
  pname = "satellite";
  version = "1.0.0";

  src = fetchFromSourcehut {
    owner = "~gsthnz";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-fOsgTuJb/UFmOKb7xV+pvqOhokEuOgt47IYDEpa0DWg=";
  };

  vendorHash = "sha256-NxfZbwKo8SY0XfWivQ42cNqIbJQ1EBsxPFr70ZU9G6E=";

  meta = with lib; {
    description = "Small Gemini server for serving static files";
    inherit (src.meta) homepage;
    license = licenses.agpl3Only;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
