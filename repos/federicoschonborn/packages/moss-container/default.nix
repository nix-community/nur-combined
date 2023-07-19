{ lib
, stdenv
, fetchFromGitHub
, ldc
, meson
, ninja
}:

stdenv.mkDerivation rec {
  pname = "moss-container";
  version = "unstable-2023-04-13";

  srcs = [
    (
      fetchFromGitHub {
        name = "moss-container";
        owner = "serpent-os";
        repo = "moss-container";
        rev = "aa296fd7672e749903a30ed675a840c9319b83c3";
        hash = "sha256-BUVFPPbW/UdRk0gnznGEpYI63+DoLvPEC8loicSeWek=";
      })

    (fetchFromGitHub {
      name = "libmoss";
      owner = "serpent-os";
      repo = "libmoss";
      rev = "v1.2.0";
      hash = "sha256-P7QUheCxwt7lTh3K1NEUas4TyojMrzTsNWj8UVQqkl0=";
    })
  ];

  sourceRoot = "moss-container";

  nativeBuildInputs = [
    ldc
    meson
    ninja
  ];

  meta = with lib; {
    description = "Manage lightweight containers";
    longDescription = ''
      Use moss-container to manage lightweight containers using Linux namespaces.
      Typically moss-container sits between boulder and mason to provide isolation
      support, however you can also use moss-container for smoketesting and
      general testing.
    '';
    homepage = "https://github.com/serpent-os/moss-container";
    license = with licenses; [ zlib ];
  };
}
