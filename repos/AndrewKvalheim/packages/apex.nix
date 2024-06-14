{ buildGoModule, fetchFromGitHub, lib }:

buildGoModule {
  pname = "apex";
  version = "1.0.0-rc4-unstable-2021-12-09";

  src = fetchFromGitHub {
    owner = "imdatngo";
    repo = "apex";
    rev = "e7e72c478a580662b3609f1a43f0e75da62b6f9b";
    hash = "sha256-U65hXHfh7AUpqMLNQxCKYEovWx+JezdpYnoNvv7apEc=";
  };

  vendorHash = "sha256-i0+EETYoDnkKTjj9Qi8nUir4iip4mQx9uIrMkY+hbDc=";

  meta = {
    description = "Build, deploy, and manage AWS Lambda functions with ease";
    homepage = "https://github.com/apex/apex";
    license = lib.licenses.mit;
  };
}
