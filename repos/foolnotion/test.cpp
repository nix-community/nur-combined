#include <boost/parser/parser.hpp>

int main()
{
  namespace bp = boost::parser;
  auto result = bp::parse("123", bp::int_);
  return result ? 0 : 1;
}
