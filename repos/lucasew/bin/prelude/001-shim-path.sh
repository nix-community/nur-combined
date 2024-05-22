
export PATH="$(
  echo "$PATH" | tr ':' '\n' | grep -v 'bin/shim' | tr '\n' ':'
):$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/../shim"
