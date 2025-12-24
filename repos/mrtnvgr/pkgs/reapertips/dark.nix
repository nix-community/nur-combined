{
  stdenvNoCC,
  lib,
  fetchFromGitHub,
  zip,
  unzip,

  variant ? "Dark",
  undimmed ? false,

  colored_track_names ? false,
}:
let
  # TODO: create a general mkReaperTheme {
  #  rtconfig = { ... };
  #  extraFiles = { ... };
  # }

  themeVersion = "1.90";

  themeDir = "Reapertips_v${themeVersion}_${variant}";

  # TODO: check if any of these have changed on update
  overrides = let
    mk = param: value: "echo \"${param} ${value}\" >> \"${themeDir}/rtconfig.txt\"";
    opt = lib.optional;
    opts = lib.optionals;

    colored_track_names_opts = opt colored_track_names (mk "colored_track_name" "1");

    undimmed_opts = opts undimmed [
      (mk "colored_track_name" "1")
      (mk "tcp_dim_sel_strength" "0")
      (mk "tcp_dim_strength" "0")
      (mk "tcp_idx_dim_strength" "0")
      (mk "tcp_idx_tint_strength" "100")
      (mk "tcp_tint_sel_strength" "100")
      (mk "tcp_tint_strength" "100")
    ];
  in
    lib.concatStringsSep "\n" (colored_track_names_opts ++ undimmed_opts);
in
stdenvNoCC.mkDerivation {
  pname = "reapertips";
  version = themeVersion;

  src = fetchFromGitHub {
    owner = "mrtnvgr";
    repo = "reapertips-theme";
    rev = "v${themeVersion}";
    hash = "sha256-rOXINkPbBqlQL/10mhdI1FhJOp0lINAREN5oo4BjB8M=";
  };

  buildInputs = [ zip unzip ];

  buildPhase = ''
    runHook preBuild

    mkdir build

    pushd build
      # TODO: use actual variant
      unzip "../02_Theme/Reapertips Theme.ReaperThemeZip"

      ${lib.optionalString undimmed ''
        cp -r ../"03_Extras/Alternative Images/Undimmed Track & Item Backgrounds"/* "${themeDir}"
      ''}

      ${overrides}

      zip -r ../result.zip *
    popd

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    cp result.zip $out

    runHook postInstall
  '';
}
