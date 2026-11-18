import dep
import gleam/io
import justin

pub fn main() {
  io.println(justin.snake_case(dep.greeting()))
}
