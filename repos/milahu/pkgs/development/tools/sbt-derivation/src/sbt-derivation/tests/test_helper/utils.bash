generate_project() {
	local options target_dir sbt_version scala_version
	local -n target_dir_var
	options=$(getopt -o '' --long sbt:,scala:,project-dir-var: -- "$@")

	eval set -- "$options"
	while true; do
		case "$1" in
			--sbt)
				shift
				sbt_version="$1"
				;;
			--scala)
				shift
				scala_version="$1"
				;;
			--project-dir-var)
				shift
				target_dir_var="$1"
				;;
			--)
				shift
				break
				;;
		esac
		shift
	done

	target_dir="$(mktemp -d "$BATS_TEST_TMPDIR/project.XXXXXXXXXX")"
	target_dir_var="$target_dir"

	echo "Creating project in $target_dir"
	mkdir -p "$target_dir/"{project,src/main/scala}
	echo "sbt.version=$sbt_version" > "$target_dir/project/build.properties"
	cat <<- EOF > "$target_dir/build.sbt"
		scalaVersion := "$scala_version"
		libraryDependencies += "org.scala-lang.modules" %% "scala-parser-combinators" % "2.1.1"
	EOF

	if [[ "$scala_version" =~ ^2 ]]; then
		cat <<- EOF > "$target_dir/src/main/scala/Main.scala"
			object Main extends App {
				println("Hello, World!")
			}
		EOF
	else
		cat <<- EOF > "$target_dir/src/main/scala/Main.scala"
			@main def hello() = println("Hello, world")
		EOF
	fi

	echo "{}" > "$target_dir/overrides.nix"
}

write_nix_config() {
	local options project_dir order=0
	options=$(getopt -o '' --long project-dir:,order: -- "$@")

	eval set -- "$options"
	while true; do
		case "$1" in
			--project-dir)
				shift
				project_dir="$1"
				;;
			--order)
				shift
				order="$1"
				;;
			--)
				shift
				break
				;;
		esac
		shift
	done

	gron -u > "$project_dir/nix-config-$order.json"
}

build_project() {
	local options project_dir compute_hash=0
	options=$(getopt -o '' --long project-dir:,compute-deps-hash -- "$@")

	eval set -- "$options"
	while true; do
		case "$1" in
			--project-dir)
				shift
				project_dir="$1"
				;;
			--compute-deps-hash)
				compute_hash=1
				;;
			--)
				shift
				break
				;;
		esac
		shift
	done

	if [[ "$compute_hash" -eq 1 ]]; then
		deps_hash="$(prepare_fresh_deps_hash --project-dir "$project_dir")"
		cat <<- EOF | write_nix_config --project-dir "$project_dir" --order 1
			depsSha256 = "$deps_hash";
		EOF
	fi

	nix-build --arg projectDir "$project_dir" "$tests_dir/test_helper/project.nix"
}

prepare_fresh_deps_hash() {
	local options project_dir
	options=$(getopt -o '' --long project-dir: -- "$@")

	eval set -- "$options"
	while true; do
		case "$1" in
			--project-dir)
				shift
				project_dir="$1"
				;;
			--)
				shift
				break
				;;
		esac
		shift
	done

	nix-prefetch -q -f "$tests_dir/test_helper/fetcher.nix" --arg projectDir "$project_dir"
}
