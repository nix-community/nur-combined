#!/usr/bin/env nu

def en [name: string] {
  rage -e $'./($name)' -i /run/agenix/id -i ./age-yubikey-identity-7d5d5540.txt.pub -o $'./($name).age'
  srm $'./($name)'
}

def de [name: string] {
  rage -d $'./($name)' -i /run/agenix/id -i ./age-yubikey-identity-7d5d5540.txt.pub
}

def main [
  name: string
  --encrypt (-e)
  --decrypt (-d)
] {
  if $decrypt {
    de $name
  } else {
    en $name
  }
}
