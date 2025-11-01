{
  buildGoModule,
  fetchFromGitHub,
  lib,
}:

buildGoModule rec {
  pname = "kroki-cli";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "yuzutech";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-KdP06tNeXPOyQB8gRYcxABHrjgzKtmxz2VudpjsofYE=";
  };

  vendorHash = "sha256-HqiNdNpNuFBfwmp2s0gsa2YVf3o0O2ILMQWfKf1Mfaw=";

  subPackages = [
    "cmd/kroki"
  ];

  meta = with lib; {
    description = "CLI for Kroki, the plain text to diagram generator";
    homepage = "https://github.com/yuzutech/kroki-cli";
    license = licenses.mit;
    mainProgram = "kroki";
    maintainers = with maintainers; [ wwmoraes ];
  };
}
