orig=$(declare -f preConfigure)
new_name="preConfigure2 ${orig#preConfigure}"
eval "$new_name"

preConfigure() {
  preConfigure2 || true
}

