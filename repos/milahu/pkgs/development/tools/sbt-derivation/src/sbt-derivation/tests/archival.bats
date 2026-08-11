setup() {
	load 'test_helper/common-setup'
	common_setup
}

@test "should generate compatible deps across copy and link strategies" {
	local project_dir
	generate_project --sbt "$latest_sbt_version" --scala "$latest_scala3_version" --project-dir-var project_dir

	cat <<- EOF | write_nix_config --project-dir "$project_dir"
		depsArchivalStrategy = "copy";
		depsOptimize = true;
	EOF

	deps_hash="$(prepare_fresh_deps_hash --project-dir "$project_dir")"
	cat <<- EOF | write_nix_config --project-dir "$project_dir" --order 1
		depsSha256 = "$deps_hash";
	EOF

	build_project --project-dir "$project_dir"

	cat <<- EOF | write_nix_config --project-dir "$project_dir" --order 2
		depsArchivalStrategy = "link";
	EOF

	build_project --project-dir "$project_dir"
}

@test "should successfully build a project with archival = copy, optimization off" {
	local project_dir
	generate_project --sbt "$latest_sbt_version" --scala "$latest_scala3_version" --project-dir-var project_dir

	cat <<- EOF | write_nix_config --project-dir "$project_dir"
		depsArchivalStrategy = "copy";
		depsOptimize = false;
	EOF

	build_project --project-dir "$project_dir" --compute-deps-hash
}

@test "should successfully build a project with archival = copy, optimization on" {
	local project_dir
	generate_project --sbt "$latest_sbt_version" --scala "$latest_scala3_version" --project-dir-var project_dir

	cat <<- EOF | write_nix_config --project-dir "$project_dir"
		depsArchivalStrategy = "copy";
		depsOptimize = true;
	EOF

	build_project --project-dir "$project_dir" --compute-deps-hash
}

@test "should successfully build a project with archival = link, optimization off" {
	local project_dir
	generate_project --sbt "$latest_sbt_version" --scala "$latest_scala3_version" --project-dir-var project_dir

	cat <<- EOF | write_nix_config --project-dir "$project_dir"
		depsArchivalStrategy = "link";
		depsOptimize = false;
	EOF

	build_project --project-dir "$project_dir" --compute-deps-hash
}

@test "should successfully build a project with archival = link, optimization on" {
	local project_dir
	generate_project --sbt "$latest_sbt_version" --scala "$latest_scala3_version" --project-dir-var project_dir

	cat <<- EOF | write_nix_config --project-dir "$project_dir"
		depsArchivalStrategy = "link";
		depsOptimize = true;
	EOF

	build_project --project-dir "$project_dir" --compute-deps-hash
}

@test "should successfully build a project with archival = tar, optimization off" {
	local project_dir
	generate_project --sbt "$latest_sbt_version" --scala "$latest_scala3_version" --project-dir-var project_dir

	cat <<- EOF | write_nix_config --project-dir "$project_dir"
		depsArchivalStrategy = "tar";
		depsOptimize = false;
	EOF

	build_project --project-dir "$project_dir" --compute-deps-hash
}

@test "should successfully build a project with archival = tar, optimization on" {
	local project_dir
	generate_project --sbt "$latest_sbt_version" --scala "$latest_scala3_version" --project-dir-var project_dir

	cat <<- EOF | write_nix_config --project-dir "$project_dir"
		depsArchivalStrategy = "tar";
		depsOptimize = true;
	EOF

	build_project --project-dir "$project_dir" --compute-deps-hash
}

@test "should successfully build a project with archival = tar+zstd, optimization off" {
	local project_dir
	generate_project --sbt "$latest_sbt_version" --scala "$latest_scala3_version" --project-dir-var project_dir

	cat <<- EOF | write_nix_config --project-dir "$project_dir"
		depsArchivalStrategy = "tar+zstd";
		depsOptimize = false;
	EOF

	build_project --project-dir "$project_dir" --compute-deps-hash
}

@test "should successfully build a project with archival = tar+zstd, optimization on" {
	local project_dir
	generate_project --sbt "$latest_sbt_version" --scala "$latest_scala3_version" --project-dir-var project_dir

	cat <<- EOF | write_nix_config --project-dir "$project_dir"
		depsArchivalStrategy = "tar+zstd";
		depsOptimize = true;
	EOF

	build_project --project-dir "$project_dir" --compute-deps-hash
}
