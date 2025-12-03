setup() {
	load 'test_helper/common-setup'
	common_setup
	load 'test_helper/bats-support/load'
	load 'test_helper/bats-assert/load'
}

@test "should override attributes of dependencies by the specified function" {
	generate_project --sbt "$latest_sbt_version" --scala "$latest_scala3_version" --project-dir-var project_dir

	cat <<- EOF > "$project_dir/nix-config-01.nix"
	{
		depsSha256 = "This is a valid";
		overrideDepsAttrs = final: prev: {
			outputHash = "";
			thisIsMe = "derivation";
			buildPhase = ''
				echo \${prev.outputHash} \${final.thisIsMe}
				exit 1
			'';
		};
	}
	EOF

	run build_project --project-dir "$project_dir"
	assert_output --partial "This is a valid derivation"
	assert_failure 1
}

@test "should consider overrides at all levels" {
	generate_project --sbt "$latest_sbt_version" --scala "$latest_scala3_version" --project-dir-var project_dir

	cat <<- EOF > "$project_dir/overrides.nix"
	let
		pkgs = import <nixpkgs> {};
	in {
		sbt = pkgs.writeShellScriptBin "sbt" ''
			echo "sbt has been overridden"
		'';
		gnutar = pkgs.writeShellScriptBin "tar" ''
			echo "tar has been overridden"
			exit 1
		'';
	}
	EOF

	cat <<- EOF | write_nix_config --project-dir "$project_dir"
		depsArchivalStrategy = "tar";
		depsOptimize = false;
	EOF

	run build_project --project-dir "$project_dir"
	assert_output --partial "sbt has been overridden"
	assert_output --partial "tar has been overridden"
	assert_failure 1
}

@test "usage through the overlay should not throw errors" {
	run nix-instantiate --eval -E - <<- EOF
	(import <nixpkgs> { overlays = [ (import ./overlay.nix) ]; }).mkSbtDerivation {
		pname = "";
		version = "";
		src = ./.;
		depsSha256 = "";
	}
	EOF

	assert_success
	assert_output --partial 'type = "derivation";'
}

@test "usage through flake outputs should not throw errors" {
	run nix-instantiate --eval -E - <<- EOF
		(builtins.getFlake "$tests_dir/..").outputs.mkSbtDerivation."\${builtins.currentSystem}" {
		pname = "";
		version = "";
		src = ./.;
		depsSha256 = "";
	}
	EOF

	assert_success
	assert_output --partial 'type = "derivation";'
}

@test "usage through flake lib should not throw errors" {
	run nix-instantiate --eval -E - <<- EOF
		(builtins.getFlake "$tests_dir/..").outputs.lib.mkSbtDerivation {
		pkgs = import <nixpkgs> {};
		pname = "";
		version = "";
		src = ./.;
		depsSha256 = "";
	}
	EOF

	assert_success
	assert_output --partial 'type = "derivation";'
}

@test "usage through default.nix should not throw errors" {
	run nix-instantiate --eval -E - <<- EOF
	(import "$tests_dir/..") {
		pkgs = import <nixpkgs> {};

		pname = "";
		version = "";
		src = ./.;
		depsSha256 = "";
	}
	EOF

	assert_success
	assert_output --partial 'type = "derivation";'
}

@test "correctly sets passthru" {
	run nix-instantiate --eval -E - <<- EOF
	((builtins.getFlake "$tests_dir/..").outputs.lib.mkSbtDerivation {
		pkgs = import <nixpkgs> {};
		pname = "";
		version = "";
		src = ./.;
		depsSha256 = "";
		passthru.foo = "bar";
	}).passthru
	EOF

	assert_success
	assert_output --partial 'foo = "bar"'
}
