{lib, fetchFromGitHub, rustPlatform}:

rustPlatform.buildRustPackage rec {
    pname = "procrastinate";
    version = "0.3.1";

    src = fetchFromGitHub {
        owner = "Wasabi375";
        repo = pname;
        rev = version;
        hash = "sha256-cSNrdeztfxxTGRK17Lcnq9MQK7R2a8HysNmJ0PMJBz0=";
    };
    
    cargoHash = "sha256-lC7VI1Z8DnoMm7smkkVCbx9IRcn/UIkTb9Xsiw2ALvI=";

    meta = with lib; {
        description = "A suite of programs to send time delayed notifications";
        homepage = "https://www.github.com/Wasabi375/procrastinate";
        license = licenses.mit;
        platforms = platforms.linux;
        mainProgram = "procrastinate";
    };
}
