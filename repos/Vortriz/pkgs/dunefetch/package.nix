{
    sources,
    lib,
    python3Packages,
}: let
    inherit (sources.dunefetch) src pname date;
in
    python3Packages.buildPythonApplication {
        inherit pname src;
        version = "unstable-${date}";

        pyproject = true;

        build-system = with python3Packages; [
            setuptools
            wheel
        ];

        dependencies = with python3Packages; [
            psutil
        ];

        pythonImportsCheck = [
            "dunefetch"
        ];

        meta = {
            description = "Neofetch + falling sand engine for your terminal";
            homepage = "https://github.com/datavorous/dunefetch";
            license = lib.licenses.mit;
            mainProgram = "dunefetch";
        };
    }
