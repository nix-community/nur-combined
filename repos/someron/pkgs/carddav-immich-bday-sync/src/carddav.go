package main

import (
	"fmt"
	"net/http"
	"strings"

	"github.com/emersion/go-vcard"
)

func FetchAddressbook(uri string, username string, password string) (*vcard.Decoder, error) {
	req, err := http.NewRequest(http.MethodGet, uri, nil)
	if err != nil {
		return nil, err
	}

	req.SetBasicAuth(username, password)

	res, err := http.DefaultClient.Do(req)
	if err != nil {
		return nil, err
	}

	return vcard.NewDecoder(res.Body), nil
}

func GetBDayInISO8001Format(card vcard.Card) (string, error) {
	bday := card.PreferredValue(vcard.FieldBirthday)

	if len(bday) == 0 {
		return "", nil
	}

	if strings.Count(bday, "-") == 0 { // bday is missing the separators for ISO 8601 format
		bday = bday[0:4] + "-" + bday[4:6] + "-" + bday[6:]
	}

	if strings.Count(bday, "-") != 2 { // bday is not in ISO 8601 format
		return "", fmt.Errorf("birthday for card %s is in invalid format %s", vcard.FieldFormattedName, bday)
	}

	return bday, nil
}
