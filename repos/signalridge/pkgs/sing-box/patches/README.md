# patches

`<module path>/NNNN-<topic>.patch`, a `git format-patch` against that module at
the version sing-box's `go.mod` pins (see the top-level README). Applied in
name order with `-p1` inside `vendor/<module path>`. Vendoring drops
`_test.go` files and `testdata/`, so a patch may add new test files but must
not modify existing ones.
