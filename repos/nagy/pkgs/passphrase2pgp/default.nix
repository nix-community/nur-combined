{ stdenv, buildGoModule, fetchFromGitHub, buildPackages, installShellFiles }:

buildGoModule rec {
  pname = "passphrase2pgp";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "skeeto";
    repo = pname;
    rev = "v${version}";
    sha256 = "0bkn7pg9i9rygdi0fh2mfn2q7ar2z87i1858af8j5r7rv7pbndrn";
  };

  vendorSha256 = "0aywf22kgbizh2wd5vnb6g4pa788bf0gb5brh3azwk7q9316gbpf";

  subPackages = [ "." ];

  outputs = [ "out" ];

  meta = with stdenv.lib; {
    description = "Generate a PGP key from a passphrase";
    homepage = "https://github.com/skeeto/passphrase2pgp";
    license = licenses.unlicense;
  };
}
