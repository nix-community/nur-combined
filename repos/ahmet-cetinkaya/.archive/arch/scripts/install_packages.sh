#!/bin/bash

# Install required dependencies
install_dependencies() {
  # Check if yay is already installed
  if pacman -Qi yay &> /dev/null; then
    echo "✅ yay is already installed."
  else
    echo "🔧 Installing yay..."
    ./yay.sh
  fi

  # Check if Bun is already installed
  if ! command -v bun &> /dev/null; then
    echo "❌ Bun not found. Installing Bun..."
    yay -S bun-bin
    export PATH="$HOME/.bun/bin:$PATH"
  else
    echo "✅ Bun is already installed."
  fi
}

# Read the YAML file and install packages
install_packages() {
  local yaml_file="../packages.yml"

  # Install dependencies first
  install_dependencies

  # Extract and process the YAML file
  while IFS=': ' read -r package manager; do
    # Skip lines that are comments or empty
    if [[ "$package" == "" || "$manager" == "" || "$manager" == \#* ]]; then
      continue
    fi

    # Remove any trailing comments from the manager
    manager=$(echo "$manager" | awk '{print $1}')

    case "$manager" in
      pacman)
        echo "📦 Installing $package with pacman..."
        sudo pacman -S --needed --noconfirm "$package"
        ;;
      yay)
        echo "📦 Installing $package with yay..."
        yay -S --needed --noconfirm "$package"
        ;;
      flatpak)
        echo "📦 Installing $package with flatpak..."
        flatpak install -y --noninteractive "$package"
        ;;
      npm)
        echo "📦 Installing $package globally with bun..."
        bun add --global "$package" --no-confirm
        ;;
      *)
        echo "❓ Unknown package manager: $manager for package $package"
        ;;
    esac
  done < <(grep -E "^[^#]" "$yaml_file")
}

# Main script execution
install_packages
