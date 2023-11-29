#!/usr/bin/env python

from pathlib import Path

template = open(".default_template.nix", "r").read()
let_tag = "<<TEMPLATE_LET>>"
package_tag = "<<TEMPLATE_PACKAGES>>"

python_versions = ["39", "310", "311"]

def main():
	pkgs = Path('pkgs')

	# get a list of all packages in pkgs (folders)
	pkg_list = [x for x in pkgs.iterdir() if x.is_dir()]
	pkg_list.sort()

	# ignore these packages
	ignore_list = ["example-package", "polydock"]
	pkg_list = [x for x in pkg_list if x.name not in ignore_list]

	######
	# Generate the let string
	######
	let_string = ""

	for p_ver in python_versions:
		let_string += f"\tp_{p_ver} = pkgs.python{p_ver}Packages;\n"

	let_string += "\n"

	# Limit packages to specific versions
	limit_python_versions = {
		"llama-cpp-python": ["310", "311"],
	}

	######
	# Generate the package string
	######

	package_string = ""
	output_packages = []
	indent = "\t"

	for pkg in pkg_list:
		pkg_dir = pkg

		# Check if the package has a default.nix
		if not (pkg_dir / "default.nix").exists():
			print(f"Package {pkg.name} does not have a default.nix -- ({pkg_dir / 'default.nix'})")
			continue

		# Check if the default.nix contains buildPythonPackage in the opening arguments
		python_package = False

		with open(pkg_dir / "default.nix") as f:
			while True:
				line = f.readline()
				if "buildPythonPackage" in line or "buildPythonApplication" in line:
					python_package = True
					break
				if "}" in line:
					break

		if python_package:
			print(f"Package {pkg.name} is a python package")
			for p_ver in python_versions:
				if pkg.name in limit_python_versions:
					if p_ver not in limit_python_versions[pkg.name]:
						continue

				package_string += f"{indent}{pkg.name}_{p_ver} = p_{p_ver}.callPackage {str(pkg)} {{python-ver = {p_ver};}};\n"
				output_packages.append(f"{pkg.name}_{p_ver}")
		else:
			print(f"Package {pkg.name} is not a python package")
			package_string += f"{indent}{pkg.name} = pkgs.callPackage {str(pkg)} {{}};\n"
			output_packages.append(pkg.name)

	package_string += "\n"

	######
	# Generate the output string
	######

	output_string = template.replace(let_tag, let_string)
	output_string = output_string.replace(package_tag, package_string)

	with open("default.nix", "w") as f:
		f.write(output_string)

	######
	# Print the output packages
	######

	if len(output_packages) == 0:
		print("No packages found")
		return 0
	else:
		print("Packages:")
		for pkg in output_packages:
			print(f"\t{pkg}")





if __name__ == '__main__':
	exit(main())
