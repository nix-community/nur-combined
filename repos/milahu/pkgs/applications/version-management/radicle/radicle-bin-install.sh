#!/bin/sh
#
# Radicle installation script.
#
set -e

url() {
  echo "https://files.radicle.xyz/latest/$1/radicle-$1.tar.gz"
}

info() {
  printf "\033[36m$*\033[0m\n"
}

success() {
  printf "\033[32m✓\033[0m Radicle was installed successfully.\n"
  printf "\n"
}

fatal() {
  printf "\033[31merror\033[0m: $*\n" >&2
  exit 1
}

target() {
  TARGET=""

  case "$(uname)/$(uname -m)" in
  Darwin/arm64)
    TARGET="aarch64-apple-darwin" ;;
  Darwin/x86_64)
    TARGET="x86_64-apple-darwin" ;;
  Linux/arm64|Linux/aarch64)
    TARGET="aarch64-unknown-linux-musl" ;;
  Linux/x86_64)
    TARGET="x86_64-unknown-linux-musl" ;;
  *)
    fatal "Your operating system is currently unsupported. Sorry!" ;;
  esac
  echo $TARGET
}

tempdir() {
  if [ -n "$TMPDIR" ]; then
    echo "$TMPDIR"
  elif [ -d "/tmp" ]; then
    echo "/tmp"
  else
    fatal "Could not locate temporary directory"
  fi
}

in_path() {
  IFS=":"

  for dir in $PATH; do
    if [ "$dir" = "$1" ]; then
      return 0 # The path is in $PATH
    fi
  done

  return 1 # The path is not in $PATH
}

echo
echo "👾 Welcome to Radicle"
echo

RAD_HOME=${RAD_HOME:-"$HOME/.radicle"}
RAD_PATH=${RAD_PATH:-"$RAD_HOME/bin"}
RAD_MANPATH=${RAD_MANPATH:-"$RAD_HOME/man"}
SHELL=${SHELL:-"/bin/sh"}

info "Detecting operating system..."
TARGET=$(target)

if ! command -v tar >/dev/null 2>&1; then
  fatal "Please install 'tar' and try again"
fi

if ! command -v curl >/dev/null 2>&1; then
  fatal "Please install 'curl' and try again"
fi

info "Installing radicle into $RAD_PATH..."
mkdir -p "$RAD_PATH"
mkdir -p "$RAD_MANPATH/man1"
curl -# -L "$(url "$TARGET")" | tar -xz --strip-components=1 -C "$RAD_PATH"
chmod +x \
  $RAD_PATH/radicle-node \
  $RAD_PATH/radicle-httpd \
  $RAD_PATH/rad \
  $RAD_PATH/git-remote-rad

info "Installing manuals into $RAD_MANPATH..."
mv "$RAD_PATH"/*.1 "$RAD_MANPATH"/man1/

# If radicle is not in $PATH, add it here.
if ! in_path $RAD_PATH; then
  DEFAULT="$HOME/.profile"

  if [ -e $HOME/.profile ]; then
    PROFILE=$DEFAULT
  else
    case $SHELL in
      */zsh)
        PROFILE=$HOME/.zshrc ;;
      */bash)
        PROFILE=$HOME/.bashrc ;;
      */fish)
        PROFILE=$HOME/.config/fish/config.fish ;;
      */csh)
        PROFILE=$HOME/.cshrc ;;
      *)
        PROFILE=$DEFAULT ;;
    esac
  fi

  info "Configuring path variable in ~${PROFILE#$HOME}..."
  echo                                    >> "$PROFILE"
  echo "# Added by Radicle."              >> "$PROFILE"
  echo "export PATH=\"\$PATH:$RAD_PATH\"" >> "$PROFILE"
  echo

  success

  printf "Before running radicle for the first time,\n"
  printf "run \033[35m\`source ~${PROFILE#$HOME}\`\033[0m or open a new terminal.\n"
  printf "\n"
else
  echo
  success
fi

printf "To get started, run \033[35m\`rad auth\`\033[0m.\n"
