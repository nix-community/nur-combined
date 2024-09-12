{lib, fetchFromGitHub, rustPlatform}:

rustPlatform.buildRustPackage rec {
    pname = "procrastinate";
    version = "0.3.2";

    src = fetchFromGitHub {
        owner = "Wasabi375";
        repo = pname;
        rev = version;
        hash = "sha256-PnrcBXn+pelVzQGGTcpGF9I69y6uxclAABilIPAzwao=";
    };
    
    cargoHash = "sha256-6aN9I/eSqF7LxytKLSlTnNz30hrxVcfPuZCiRFAgWtE=";

    meta = with lib; {
        description = "A suite of programs to send time delayed notifications";
        homepage = "https://www.github.com/Wasabi375/procrastinate";
        license = licenses.mit;
        platforms = platforms.linux;
        mainProgram = "procrastinate";
    };
}
