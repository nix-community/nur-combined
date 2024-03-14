#!/usr/bin/env nix-shell
#!nix-shell -i bash -p nix-prefetch-git -p jq
#shellcheck shell=bash disable=SC2016

declare -A list=(
	["WhatsApp/tree-sitter-erlang"]=54b6f814f43c4eac81eeedefaa7cc8762fec6683
	["Azganoth/tree-sitter-lua"]=6b02dfd7f07f36c223270e97eb0adf84e15a4cef
	["Wilfred/tree-sitter-elisp"]=4b0e4a3891337514126ec72c7af394c0ff2cf48c
	["ZedThree/tree-sitter-fixed-form-fortran"]=3142d317c73de80882beb95cc431af7eb6c28c51
	["alemuller/tree-sitter-make"]=a4b9187417d6be349ee5fd4b6e77b4172c6827dd
	["camdencheek/tree-sitter-dockerfile"]=25c71d6a24cdba8f0c74ef40d4d2d93defd7e196
	["camdencheek/tree-sitter-go-mod"]=4a65743dbc2bb3094114dd2b43da03c820aa5234
	["dhcmrlchtdj/tree-sitter-sqlite"]=993be0a91c0c90b0cc7799e6ff65922390e2cefe
	["elixir-lang/tree-sitter-elixir"]=11426c5fd20eef360d5ecaf10729191f6bc5d715
	["elm-tooling/tree-sitter-elm"]=c26afd7f2316f689410a1622f1780eff054994b1
	["fwcd/tree-sitter-kotlin"]=0ef87892401bb01c84b40916e1f150197bc134b1
	["ganezdragon/tree-sitter-perl"]=15a6914b9b891974c888ba7bf6c432665b920a3f
	["ikatyang/tree-sitter-markdown"]=8b8b77af0493e26d378135a3e7f5ae25b555b375
	["ikatyang/tree-sitter-yaml"]=0e36bed171768908f331ff7dff9d956bae016efb
	["jiyee/tree-sitter-objc"]=afec0de5a32d5894070b67932d6ff09e4f7c5879
	["m-novikov/tree-sitter-sql"]=218b672499729ef71e4d66a949e4a1614488aeaa
	["MichaHoffmann/tree-sitter-hcl"]=e135399cb31b95fac0760b094556d1d5ce84acf0
	["r-lib/tree-sitter-r"]=c55f8b4dfaa32c80ddef6c0ac0e79b05cb0cbf57
	["rydesun/tree-sitter-dot"]=917230743aa10f45a408fea2ddb54bbbf5fbe7b7
	["slackhq/tree-sitter-hack"]=fca1e294f6dce8ec5659233a6a21f5bd0ed5b4f2
	["stadelmanma/tree-sitter-fortran"]=f73d473e3530862dee7cbb38520f28824e7804f6
	["stsewd/tree-sitter-rst"]=3ba9eb9b5a47aadb1f2356a3cab0dd3d2bd00b4b
	["theHamsta/tree-sitter-commonlisp"]=c7e814975ab0d0d04333d1f32391c41180c58919
	["tree-sitter/tree-sitter-bash"]=f7239f638d3dc16762563a9027faeee518ce1bd9
	["tree-sitter/tree-sitter-c"]=34f4c7e751f4d661be3e23682fe2631d6615141d
	["tree-sitter/tree-sitter-c-sharp"]=dd5e59721a5f8dae34604060833902b882023aaf
	["tree-sitter/tree-sitter-cpp"]=a71474021410973b29bfe99440d57bcd750246b1
	["tree-sitter/tree-sitter-css"]=98c7b3dceb24f1ee17f1322f3947e55638251c37
	["tree-sitter/tree-sitter-embedded-template"]=203f7bd3c1bbfbd98fc19add4b8fcb213c059205
	["tree-sitter/tree-sitter-go"]=ff86c7f1734873c8c4874ca4dd95603695686d7a
	["tree-sitter/tree-sitter-haskell"]=dd924b8df1eb76261f009e149fc6f3291c5081c2
	["tree-sitter/tree-sitter-html"]=949b78051835564bca937565241e5e337d838502
	["tree-sitter/tree-sitter-java"]=2b57cd9541f9fd3a89207d054ce8fbe72657c444
	["tree-sitter/tree-sitter-javascript"]=f1e5a09b8d02f8209a68249c93f0ad647b228e6e
	["tree-sitter/tree-sitter-jsdoc"]=d01984de49927c979b46ea5c01b78c8ddd79baf9
	["tree-sitter/tree-sitter-json"]=3fef30de8aee74600f25ec2e319b62a1a870d51e
	["tree-sitter/tree-sitter-julia"]=0c088d1ad270f02c4e84189247ac7001e86fe342
	["tree-sitter/tree-sitter-ocaml"]=4abfdc1c7af2c6c77a370aee974627be1c285b3b
	["tree-sitter/tree-sitter-php"]=33e30169e6f9bb29845c80afaa62a4a87f23f6d6
	["tree-sitter/tree-sitter-python"]=4bfdd9033a2225cc95032ce77066b7aeca9e2efc
	["tree-sitter/tree-sitter-ql"]=bd087020f0d8c183080ca615d38de0ec827aeeaf
	["tree-sitter/tree-sitter-regex"]=2354482d7e2e8f8ff33c1ef6c8aa5690410fbc96
	["tree-sitter/tree-sitter-ruby"]=4d9ad3f010fdc47a8433adcf9ae30c8eb8475ae7
	["tree-sitter/tree-sitter-rust"]=e0e8b6de6e4aa354749c794f5f36a906dcccda74
	["tree-sitter/tree-sitter-scala"]=45b5ba0e749a8477a8fd2666f082f352859bdc3c
	["tree-sitter/tree-sitter-toml"]=342d9be207c2dba869b9967124c679b5e6fd0ebe
	["tree-sitter/tree-sitter-tsq"]=b665659d3238e6036e22ed0e24935e60efb39415
	["tree-sitter/tree-sitter-typescript"]=d847898fec3fe596798c9fda55cb8c05a799001a
)

echo "# Generated using generateFetchLanguages.sh"
echo "fetchFromGitHub:"
echo \'\'
echo "  mkdir -p vendor"
for repo in "${!list[@]}"; do
	rev=${list[$repo]}
	owner=${repo%%/*}
	project=${repo##*/}
	echo '  ln -sv ${fetchFromGitHub {'
	echo "    owner = \"$owner\";"
	echo "    repo = \"$project\";"
	nix-prefetch-git --quiet --rev "$rev" "https://github.com/$owner/$project" |
		jq '  { rev: .rev, sha256: .sha256 }' |
		jq -r 'to_entries | map("  \(.key) = \"\(.value)\";") | .[]'
	echo "  }} vendor/$project"
done
echo '  python build.py'
echo \'\'
