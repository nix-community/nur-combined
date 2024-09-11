{lib, fetchFromGitHub, rustPlatform}:

rustPlatform.buildRustPackage rec {
    pname = "procrastinate";
    version = "0.3.0";

    src = fetchFromGitHub {
        owner = "Wasabi375";
        repo = pname;
        rev = version;
        hash = "sha256-rt9K51GBXmBa5HsvyJT9VnYckWnc0NxBFnwpzYqk1WQ=";
    };
    
    cargoHash = "sha256-4zE9CA7swIYsbYlGdVmOM8EZviamNZwugPPKI+oLXGU=";

    meta = with lib; {
        description = "A suite of programs to send time delayed notifications";
        homepage = "https://www.github.com/Wasabi375/procrastinate";
        license = licenses.mit;
        platforms = platforms.linux;
        mainProgram = "procrastinate";
    };
}
