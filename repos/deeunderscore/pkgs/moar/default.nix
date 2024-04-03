{ buildGoModule, fetchFromGitHub }:
buildGoModule rec {
  pname = "moar-pager"; # not to be confused with moarvm 
  version = "1.9.0";

  src = fetchFromGitHub {
    owner = "walles";
    repo = "moar";
    rev = "v${version}";
    sha256 = "sha256-uz+7Pjf4vi9k7jLvc3db+5xuFEuiSQg5/iZRz6QFN7M=";
  };

  vendorHash = "sha256-Ldks6lmMBQrm5NaQ5tFjrT8f8Nbd10gJH3ZAhwTH9Xk=";

  ldflags = [
    "-s" "-w"
    "-X main.versionString=${version}"
  ];

  # tests cannot find the sample files dir
  doCheck = false;

  meta = {
    description = "A terminal pager";
    homepage = "https://github.com/walles/moar";
    license = {
      spdxId = "BSD-2-Clause-FreeBSD";
      fullName = "BSD 2-Clause FreeBSD License";
    };
  };
}