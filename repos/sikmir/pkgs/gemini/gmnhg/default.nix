{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "gmnhg";
  version = "0.4.2";

  src = fetchFromGitHub {
    owner = "tdemin";
    repo = "gmnhg";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ob1bt9SX9qFd9GQ5d8g+fS4z+aT9ob3a7iLY8zjUCp8=";
  };

  vendorHash = "sha256-Jiud36qgjj7RlJ7LysTlhKQhHK7C116lxbw1Cj2hHmU=";

  meta = {
    description = "Hugo-to-Gemini Markdown converter";
    homepage = "https://github.com/tdemin/gmnhg";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.sikmir ];
  };
})
