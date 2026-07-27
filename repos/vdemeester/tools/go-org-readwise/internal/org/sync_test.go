package org

import "testing"

func TestSluggify(t *testing.T) {
	testCases := []struct {
		input    string
		expected string
	}{{
		input:    "",
		expected: "",
	}, {
		input:    "abcde",
		expected: "abcde",
	}, {
		input:    "abcde---",
		expected: "abcde",
	}, {
		input:    "a-b c--de",
		expected: "a-b-c-de",
	}, {
		input:    "a_bc__de",
		expected: "a-bc-de",
	}, {
		input:    "abcde$[)",
		expected: "abcde",
	}}
	for _, tc := range testCases {
		output := sluggify(tc.input)
		if output != tc.expected {
			t.Errorf("input \"%s\": expected %s, got %s", tc.input, tc.expected, output)
		}
	}
}
