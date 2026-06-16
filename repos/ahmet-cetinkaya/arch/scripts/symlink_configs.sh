#!/bin/bash

# Function to remove existing target
remove_existing_target() {
  local target="$1"
  if [ -e "$target" ]; then
    echo "⚠️ Target exists: $target"
    read -r -p "Do you want to remove this target? (y/n): " confirmation

    if [ "$confirmation" = "y" ]; then
      echo "🗑️ Removing target: $target"
      rm -rf "$target"
    else
      echo "❌ Operation cancelled for target: $target"
      exit 1
    fi
  fi
}

# Function to create directories if they do not exist
create_directories() {
  local dir="$1"
  if [ ! -d "$dir" ]; then
    echo "🔧 Creating directory: $dir"
    mkdir -p "$dir"
  fi
}

# Basic symlink creation
declare -A links
links=(
  ["$HOME/Configs/fastfetch"]="$HOME/.config/fastfetch"
  ["$HOME/Configs/zsh/.zshrc"]="$HOME/.zshrc"
  ["$HOME/vs-codium/settings.json"]="$HOME/.config/VSCodium/User/settings.json"
  ["$HOME/Configs/vs-codium/product.json"]="$HOME/.config/VSCodium/product.json"
)

for source in "${!links[@]}"; do
  target="${links[$source]}"

  remove_existing_target "$target"

  echo "🔗 Creating symlink for file: $target"
  ln -s "$source" "$target"
done

echo "✅ Basic symlink operations completed."

# Floorp profile symlink creation
read -r -p "Enter the Floorp profile ID (e.g., rw8fe1of.default-release): " PROFILE_ID

SOURCE_USER_JS="$HOME/Configs/firefox/user.js"
TARGET_USER_JS="$HOME/.var/app/one.ablaze.floorp/cache/floorp/$PROFILE_ID/user.js"

SOURCE_CHROME="$HOME/Configs/firefox/chrome/"
TARGET_CHROME="$HOME/.var/app/one.ablaze.floorp/cache/floorp/$PROFILE_ID/"

# Ensure the target directories exist
create_directories "$(dirname "$TARGET_USER_JS")"
create_directories "$(dirname "$TARGET_CHROME")"

# Remove existing target if it exists
remove_existing_target "$TARGET_USER_JS"
remove_existing_target "$TARGET_CHROME/chrome"

# Create symlinks
echo "🔗 Creating symlink for file: $TARGET_USER_JS"
ln -s "$SOURCE_USER_JS" "$TARGET_USER_JS"

echo "🔗 Creating symlink for directory: $TARGET_CHROME"
ln -s "$SOURCE_CHROME" "$TARGET_CHROME"

echo "✅ All operations, including Floorp profile symlinks, completed."
