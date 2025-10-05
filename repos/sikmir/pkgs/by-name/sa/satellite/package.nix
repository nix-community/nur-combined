{
  lib,
  buildGoModule,
  fetchFromSourcehut,
}:

buildGoModule (finalAttrs: {
  pname = "satellite";
  version = "1.0.0";

  src = fetchFromSourcehut {
    owner = "~gsthnz";
    repo = "satellite";
    rev = "v${finalAttrs.version}";
    hash = "sha256-fOsgTuJb/UFmOKb7xV+pvqOhokEuOgt47IYDEpa0DWg=";
  };

  vendorHash = "sha256-NxfZbwKo8SY0XfWivQ42cNqIbJQ1EBsxPFr70ZU9G6E=";

  meta = {
    description = "Small Gemini server for serving static files";
    homepage = "https://sr.ht/~gsthnz/satellite";
    license = lib.licenses.agpl3Only;
    maintainers = [ lib.maintainers.sikmir ];
  };
})
