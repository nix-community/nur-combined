{ buildGoModule, fetchFromGitHub, lib }:

buildGoModule rec {
  pname = "easy-novnc";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "pgaskin";
    repo = "easy-novnc";
    rev = "v${version}";
    sha256 = "0y7ia3z6mv4wr1jqnhd4pnw2zdwr5r5prm3ybffnx8y1hr2x13m2";
  };

  vendorSha256 = "1vmnxn8hx5bs060phc0x3l4jlr8q02nz75fa1x04p1c36d8xd08m";
  modSha256 = vendorSha256;

  doCheck = false;

  meta = with lib; {
    description =
      "An easy way to run a noVNC instance and proxy with a single binary";
    homepage = "https://github.com/pgaskin/easy-novnc";
    license = licenses.mit;
    maintainers = with maintainers; [ htr ];
  };
}
