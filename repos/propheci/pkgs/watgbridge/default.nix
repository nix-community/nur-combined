{ lib
, buildGoModule
, fetchFromGitHub
, libwebp
}:

buildGoModule rec {
    pname = "watgbridge";
    version = "1.8.2";

    src = fetchFromGitHub {
        owner = "akshettrj";
        repo = "watgbridge";
        rev = "v${version}";
        hash = "sha256-/RTh1rPr54aO750rN5somel3fXxiUp3SPEfa95+V7q8=";
    };

    vendorHash = "sha256-qbQPbRSNw4E5gOYpDFSihMSgiRCC3BDXjeOoiMBEYro=";

    ldflags = [ "-s" "-w" ];

    buildInputs = [ libwebp ];

    meta = with lib; {
        description = "A bridge between WhatsApp and Telegram written in Golang";
        homepage = "https://github.com/akshettrj/watgbridge";
        changelog = "https://github.com/akshettrj/watgbridge/releases/tag/v${version}";
        license = licenses.mit;
        mainProgram = "watgbridge";
    };
}

