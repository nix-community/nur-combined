setup() {
	load 'test_helper/common-setup'
	common_setup
}

### CUT HERE

@test "should successfully build a project with sbt 1.6.2 and scala 2.13.8" {
	local project_dir
	generate_project --sbt 1.6.2 --scala 2.13.8 --project-dir-var project_dir
	build_project --project-dir "$project_dir" --compute-deps-hash
}

@test "should successfully build a project with sbt 1.7.3 and scala 2.13.8" {
	local project_dir
	generate_project --sbt 1.7.3 --scala 2.13.8 --project-dir-var project_dir
	build_project --project-dir "$project_dir" --compute-deps-hash
}

@test "should successfully build a project with sbt 1.7.3 and scala 3.2.1" {
	local project_dir
	generate_project --sbt 1.7.3 --scala 3.2.1 --project-dir-var project_dir
	build_project --project-dir "$project_dir" --compute-deps-hash
}

@test "should successfully build a project with sbt 1.8.0 and scala 2.13.8" {
	local project_dir
	generate_project --sbt 1.8.0 --scala 2.13.8 --project-dir-var project_dir
	build_project --project-dir "$project_dir" --compute-deps-hash
}

@test "should successfully build a project with sbt 1.8.0 and scala 3.2.1" {
	local project_dir
	generate_project --sbt 1.8.0 --scala 3.2.1 --project-dir-var project_dir
	build_project --project-dir "$project_dir" --compute-deps-hash
}

