{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "gpxgo";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "tkrajina";
    repo = "gpxgo";
    tag = "v${finalAttrs.version}";
    hash = "sha256-hSqu8WTHMJqQUKTZRygVdXbOLiImOUKIndNqFYJq+80=";
  };

  vendorHash = "sha256-iX7Vqj/4MIK1EGuTJzrZgY8wNXX1PtIavw+qDfkV0uc=";

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "GPX library for golang";
    homepage = "https://github.com/tkrajina/gpxgo";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.sikmir ];
  };
})
