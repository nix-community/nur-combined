module example.com/fixture

go 1.22

require (
	example.com/dep v0.0.0
	github.com/google/uuid v1.6.0
)

replace example.com/dep => ./dep

// a version replacement, to test how it's vendored
replace github.com/google/uuid => github.com/google/uuid v1.5.0
