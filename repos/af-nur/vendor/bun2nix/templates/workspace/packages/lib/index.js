const isOdd = require("is-odd");

function isEven(num) {
  return !isOdd(num);
}

module.exports = {
  isOdd,
  isEven,
};
