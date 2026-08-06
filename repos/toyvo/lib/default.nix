{
  lib,
  inputs,
}:
let
  shouldRecurseForDerivations = p: lib.isAttrs p && p.recurseForDerivations or false;

  flattenPkgs =
    s:
    let
      f =
        p:
        if shouldRecurseForDerivations p then
          flattenPkgs p
        else if lib.isDerivation p then
          [ p ]
        else
          [ ];
    in
    builtins.concatMap f (builtins.attrValues s);
in
{
  # Add your library functions here
  #
  # hexint = x: hexvals.${toLower x};
  maintainers.toyvo = {
    name = "Collin Diekvoss";
    email = "Collin@Diekvoss.com";
    matrix = "@toyvo:matrix.org";
    github = "ToyVo";
    githubId = 5168912;
  };

  isReserved =
    n:
    n == "lib"
    || n == "overlays"
    || n == "modules"
    || n == "nixosModules"
    || n == "homeModules"
    || n == "darwinModules"
    || n == "flakeModules";
  isBuildable =
    p:
    let
      licenseFromMeta = p.meta.license or [ ];
      licenseList = if builtins.isList licenseFromMeta then licenseFromMeta else [ licenseFromMeta ];
    in
    !(p.meta.broken or false) && builtins.all (license: license.free or true) licenseList;
  isCacheable = p: !(p.preferLocalBuild or false);

  inherit shouldRecurseForDerivations flattenPkgs;

  outputsOf = p: map (o: p.${o}) p.outputs;

  forSystem =
    system: p:
    (builtins.any (s: s == system) (p.meta.platforms or [ system ]))
    && !(builtins.any (s: s == system) (p.meta.badPlatforms or [ ]));

  mkWrappedProgram =
    pkgs:
    {
      name,
      package,
      binaryName ? package.meta.mainProgram or (lib.getName package),
      configDir ? null,
      envVars ? { },
      extraFlags ? [ ],
      runtimeDeps ? [ ],
      extraBinaries ? [ ],
    }:

    pkgs.runCommand name
      {
        nativeBuildInputs = [ pkgs.makeWrapper ];
        meta = package.meta // {
          description = "${package.meta.description or binaryName} with bundled configuration";
        };
      }
      ''
        mkdir -p $out/bin

        makeWrapper ${lib.getExe package} $out/bin/${binaryName} \
          ${lib.optionalString (configDir != null) "--set XDG_CONFIG_HOME ${configDir}"} \
          ${lib.optionalString (runtimeDeps != [ ]) "--prefix PATH : ${lib.makeBinPath runtimeDeps}"} \
          ${lib.concatMapStringsSep " " (n: "--set ${n} \"${envVars.${n}}\"") (lib.attrNames envVars)} \
          ${lib.concatMapStringsSep " " (flag: "--add-flags \"${flag}\"") extraFlags}

        ${lib.concatMapStringsSep "\n" (
          binName: "ln -s $out/bin/${binaryName} $out/bin/${binName}"
        ) extraBinaries}
      '';
}
