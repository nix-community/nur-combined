{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "mkat";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "DataDog";
    repo = "managed-kubernetes-auditing-toolkit";
    rev = "v${version}";
    hash = "sha256-VnLqJcbuZH56LaIC7w8PF2IliBsa6Bp/HF5HiC+iLoM=";
  };

  vendorHash = "sha256-Dn7m7WO8alEvX7TcPPPyiiXeqAl74/h3ajdzU/hMFfM=";

  doCheck = false;

  meta = {
    description = "All-in-one auditing toolkit for identifying common security issues in managed Kubernetes environments. Currently supports Amazon EKS";
    homepage = "https://github.com/DataDog/managed-kubernetes-auditing-toolkit";
    mainProgram = "managed-kubernetes-auditing-toolkit";
    licenses = lib.licenses.asl20;
  };
}
