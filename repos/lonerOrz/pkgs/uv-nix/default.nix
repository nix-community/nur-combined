{
  lib,
  git,
  uv,
  writeShellApplication,
}:

writeShellApplication {
  name = "mkproject";

  runtimeInputs = [
    git
    uv
  ];

  text = ''
      set -euo pipefail

      if [ -z "''${1-}" ]; then
        echo "Usage: mkproject <project-name>"
        exit 1
      fi

      name="$1"
      echo "📦 Creating project: $name"

      git clone https://github.com/lonerOrz/uv-python-nix-template.git "$name"
      cd "$name"
      rm -rf .git
      rm README.md
      git init
      git add .

      echo "▶ Creating pyproject.toml ..."
      cat > pyproject.toml <<EOF
    [project]
    name = "$name"
    version = "0.1.0"
    requires-python = ">=3.9,<=3.13"
    EOF

      if command -v direnv >/dev/null 2>&1; then
        echo "▶ Creating .envrc"
        cat > .envrc <<EOF
    use flake
    EOF
        direnv allow .
      else
        echo "⚠️ No direnv — skipping .envrc"
      fi

      echo "▶ Running uv lock ..."
      git add .
      uv lock || true

      echo "🎉 Project '$name' created!"
  '';
  meta = {
    description = "Using Nix to manage UV-based Python projects";
    homepage = "https://github.com/lonerOrz/uv-python-nix-template";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ lonerOrz ];
    mainProgram = "mkproject";
  };
}
