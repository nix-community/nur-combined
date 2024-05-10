{lib, fetchFromGitHub, rustPlatform}:

rustPlatform.buildRustPackage rec {
    pname = "procrastinate";
    version = "0.2.1";

    src = fetchFromGitHub {
        owner = "Wasabi375";
        repo = pname;
        rev = version;
        hash = "sha256-hYWc27YdApT/YRbsyZkE2ywGuGJpLhNO6eechG4xlh0=";
    };
    
    cargoHash = "sha256-pry7nC/oIX82Se7wRgKdiThC57LkhTEWSoIe2GYdglc=";

    meta = with lib; {
        description = "A suite of programs to send time delayed notifications";
        homepage = "https://www.github.com/Wasabi375/procrastinate";
        license = licenses.mit;
        platforms = platforms.linux;
        mainProgram = "procrastinate";
    };
}
