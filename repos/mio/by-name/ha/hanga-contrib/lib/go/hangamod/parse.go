package hangamod

import "strconv"

func parseInt64(text string) (int64, error) {
	return strconv.ParseInt(text, 10, 64)
}
