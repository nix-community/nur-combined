{ lib, fetchFromGitHub, stdenv, autoreconfHook
, ncurses
, sensorsSupport ? stdenv.isLinux, lm_sensors
, systemdSupport ? stdenv.isLinux, systemd
}:

with lib;

assert systemdSupport -> stdenv.isLinux;

stdenv.mkDerivation rec {
  pname = "htop";
  version = "3.1.0";

  src = fetchFromGitHub {
    owner = "htop-dev";
    repo = pname;
    rev = "a8637afe0398f0be0131f73563b55ef9315ca351";
    sha256 = "sha256-/48Ca7JPzhPS4eYsPbwbSVcx9aS1f0LHcqsbNVWL+9k=";
  };

  patches = ./htop-solarized.patch;

  nativeBuildInputs = [ autoreconfHook ];

  buildInputs = [ ncurses ]
    ++ optional sensorsSupport lm_sensors
    ++ optional systemdSupport systemd
  ;

  configureFlags = [ "--enable-unicode" "--sysconfdir=/etc" ]
    ++ optional sensorsSupport "--with-sensors"
  ;

  postFixup =
    let
      optionalPatch = pred: so: optionalString pred "patchelf --add-needed ${so} $out/bin/htop";
    in
    ''
      ${optionalPatch sensorsSupport "${lm_sensors}/lib/libsensors.so"}
      ${optionalPatch systemdSupport "${systemd}/lib/libsystemd.so"}
    '';

  meta = {
    description = "Interactive process viewer with solarized patch";
    homepage = "https://aur.archlinux.org/packages/htop-solarized";
    license = licenses.gpl2Only;
    platforms = platforms.all;
    maintainers = with maintainers; [ dan4ik605743 ];
  };
}
