gtest_dep = dependency(
  'gtest',
  main : true,
  required : false,
)

dummy_test = executable(
  'testprog',
  'dummy_test.cc',
  dependencies : gtest_dep,
)

test('dummy test', dummy_test)
