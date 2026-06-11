// Javascript, please, I beg of you, JUST OFFER A USEFUL ENCODING FUNCTION FFS
// (To better understand this message, look at the history of this file)
function b64Recode(value) {
  let enc = JSON.stringify([...JSON.stringify(value)].map(char => char.charCodeAt(0)));
  return `JSON.parse(JSON.parse("${enc}").map(char => String.fromCharCode(char)).join(''))`;
}
