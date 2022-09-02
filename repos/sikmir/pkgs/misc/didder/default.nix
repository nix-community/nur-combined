{ lib, buildGoModule, fetchFromGitHub, installShellFiles }:

buildGoModule rec {
  pname = "didder";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "makeworld-the-better-one";
    repo = "didder";
    rev = "v${version}";
    hash = "sha256-3tK7UaHzARlrhT1hzlekwSqclrDwoSv+vHzpSPTmxrs=";
  };

  vendorHash = "sha256-U82CJIFZOkvKeiIHDAy1+AAg/mecSA+QzeQh+70X8Mo=";

  nativeBuildInputs = [ installShellFiles ];

  postInstall = ''
    installManPage didder.1
  '';

  meta = with lib; {
    description = "An extensive, fast, and accurate command-line image dithering tool";
    inherit (src.meta) homepage;
    license = licenses.gpl3Only;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
