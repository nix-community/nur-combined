{lib, fetchFromGitHub, rustPlatform}:

rustPlatform.buildRustPackage rec {
    pname = "procrastinate";
    version = "0.3.1";

    src = fetchFromGitHub {
        owner = "Wasabi375";
        repo = pname;
        rev = version;
        hash = "sha256-CNAkVGKUywtSqVN2wBDbSZVSbGE+IWKCqq8NqwU3nKo=";
    };
    
    cargoHash = "sha256-JX20LDb7SWCeXRR2DnufMJV0CCdXFvESviJfhzKKugA=";

    meta = with lib; {
        description = "A suite of programs to send time delayed notifications";
        homepage = "https://www.github.com/Wasabi375/procrastinate";
        license = licenses.mit;
        platforms = platforms.linux;
        mainProgram = "procrastinate";
    };
}
