{ lib
, buildGoModule
, fetchFromGitHub
}:
buildGoModule {
  pname = "glyphs";
  version = "2024-02-08";

  src = fetchFromGitHub {
    owner = "maaslalani";
    repo = "glyphs";
    rev = "b51340f85d9323ed214b55135c939f59934af90a";
    hash = "sha256-HRfjEka6kl29tWf3zUZzOsdHb3+6zfhF6eq5gknn6ys=";
  };

  vendorHash = "sha256-R1M74SGmooHIsFUkqF4Vj52znKDsXyezrmL9o3fBDws=";

  doCheck = false;

  meta = with lib; {
    description = "Unicode symbols on the command line";
    homepage = "https://github.com/maaslalani/glyphs";
    changelog = "https://github.com/maaslalani/glyphs/commits";
    maintainers = with maintainers; [ caarlos0 ];
    mainProgram = "glyphs";
  };
}
