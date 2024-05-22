{ fetchurl }:
let
  fetchSrtm =
    { file, hash }:
    fetchurl {
      inherit hash;
      url = "https://srtm.kurviger.de/SRTM3/${file}";
    };
in
[
  (fetchSrtm {
    file = "Eurasia/N47E013.hgt.zip";
    hash = "sha256-VA4wiiPODvHNMTAN+Gk6YJzJPbeIoJm/xL+ZaM1PGS0=";
  })
  (fetchSrtm {
    file = "Eurasia/N46E013.hgt.zip";
    hash = "sha256-77VJEdbIR8vexa0VUB2U/x5UQotjvAk0fcvYE+ffN5I=";
  })
  (fetchSrtm {
    file = "Eurasia/N47E012.hgt.zip";
    hash = "sha256-FplC/gd0CiLjsZOH1cOFWXqFye++JjGnTVKyXpPSZXI=";
  })
  (fetchSrtm {
    file = "Africa/N00E015.hgt.zip";
    hash = "sha256-Sj5pOoKtxjzwVzmMRhva+6nPXAqsvpXFoD0T7oTpSew=";
  })
  (fetchSrtm {
    file = "Africa/S01E015.hgt.zip";
    hash = "sha256-lrQ5/ivQ1/OG+s7lAjGpQ5VgRB0pCPVZOP62017dpGg=";
  })
  (fetchSrtm {
    file = "Eurasia/N51E000.hgt.zip";
    hash = "sha256-hwxaZfZwEMp3vetsxBBBmoDWHemXgozAX5A9igPG2SU=";
  })
  (fetchSrtm {
    file = "Eurasia/N51W001.hgt.zip";
    hash = "sha256-l8teYdCYG3a7XMtdekyRlTaJ2FLVoBgRGjM++FZiE1w=";
  })
  (fetchSrtm {
    file = "Eurasia/N42E071.hgt.zip";
    hash = "sha256-OH9he4a+rs55g7Hb4P5a4PJc2QASmytNAZOfszZ5t2M=";
  })
  (fetchSrtm {
    file = "Eurasia/N43E087.hgt.zip";
    hash = "sha256-sBPuvLco0MoWb81NAHOvi5nY1aPNZlcUJzqS+KaWeEE=";
  })
  (fetchSrtm {
    file = "Africa/N31E035.hgt.zip";
    hash = "sha256-SO0dSS3jNWKTssoEQ3vB/XlL3AST9laHVr9XTvN3QDw=";
  })
  (fetchSrtm {
    file = "Eurasia/N55E055.hgt.zip";
    hash = "sha256-IqO9AUJ3EdGd0LS1y4hcrz20vyXS23KXSaOSLjP0pFo=";
  })
  (fetchSrtm {
    file = "Eurasia/N45E013.hgt.zip";
    hash = "sha256-y5Ykg4Sl4L0YVVS89bOdT6bn13xEgrmkTEKjf3gWALk=";
  })
  (fetchSrtm {
    file = "Africa/N24E035.hgt.zip";
    hash = "sha256-G4tkOIt4uKO9o1wmXzaqwvnLuB1RSFikOyEfU9vy2bs=";
  })
]
