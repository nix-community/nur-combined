// vim: set shiftwidth=2 :
use strings;
use types;
use types::c;

// create a NULL-terminated kernel-compatible string from a Hare string.
// this either:
// - a. modifies the string in-place to add a NULL terminator -- without
//      modifying its length.
// - b. copies the string into the provided buffer, assumed to be zero'd.
// which one happens is a matter of if the string has capacity for a NULL
// without re-allocating.
fn make_cstr(scratch: []c::char, s: str) *c::char = {
  let s_repr = &s: *types::string;
  if (s_repr.length < s_repr.capacity) {
    match (s_repr.data) {
      case null => void;
      case let data: *[*]u8 =>
        data[s_repr.length] = 0;
        return data: *c::char;
    };
  };
  // XXX: will `abort` if the string is larger than the buffer!
  return c::fromstr_buf(s, scratch);
};

@test fn make_cstr_empty() void = {
  let buf: [4095]c::char = [0...];
  let ptr = make_cstr(&buf, "");
  assert(*ptr == 0);
};

@test fn make_cstr_static() void = {
  let buf: [4095]c::char = [0...];
  let ptr = make_cstr(&buf, "abcdefgh"): *[*]c::char;
  assert(ptr[0] == 'a');
  assert(ptr[7] == 'h');
  assert(ptr[8] == 0);
};

@test fn make_cstr_dynamic_no_room() void = {
  let my_str = strings::dup("abcdefgh");  //< `dup` returns a string with `length` == `capacity`
  defer free(my_str);
  let buf: [4095]c::char = [0...];
  let ptr = make_cstr(&buf, my_str): *[*]c::char;
  assert(ptr[0] == 'a');
  assert(ptr[7] == 'h');
  assert(ptr[8] == 0);
};

@test fn make_cstr_dynamic_has_room() void = {
  let my_str = strings::dup("abcdefghi");
  defer free(my_str);
  let buf: [4095]c::char = [0...];
  let ptr = make_cstr(&buf, strings::sub(my_str, 0, 8)): *[*]c::char;
  assert(ptr[0] == 'a');
  assert(ptr[7] == 'h');
  assert(ptr[8] == 0);
};

