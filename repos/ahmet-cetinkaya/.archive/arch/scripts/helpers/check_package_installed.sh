#!/bin/bash

# Get the package or group name from the user
package_or_group="$1"

if [ -z "$package_or_group" ]; then
  echo "Please provide a package or group name."
  exit 1
fi

# Check if the given name is an installed package
if pacman -Q "$package_or_group" &> /dev/null; then
  echo "Yes, $package_or_group package is installed on the system."
  exit 0
fi

# Check if the given name could be a group
group_packages=$(pacman -Qg "$package_or_group" 2> /dev/null | awk '{print $2}')

if [ -n "$group_packages" ]; then
  # Check if all packages in the group are installed
  group_installed=true
  for package in $group_packages; do
    if ! pacman -Q "$package" &> /dev/null; then
      group_installed=false
      break
    fi
  done

  if [ "$group_installed" = true ]; then
    echo "Yes, $package_or_group group is installed on the system."
    exit 0
  else
    echo "No, $package_or_group group is not fully installed on the system."
    exit 1
  fi
else
  echo "No, $package_or_group is not installed on the system."
  exit 1
fi
