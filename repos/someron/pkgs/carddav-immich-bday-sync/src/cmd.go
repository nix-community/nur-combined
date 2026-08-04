package main

import (
	"fmt"
	"io"
	"os"

	"github.com/emersion/go-vcard"
)

func main() {
	carddavUri := getRequiredEnvVariable("CARDDAV_IMMICH_BDAY_SYNC_CARDDAV_URL")
	carddavUser := getRequiredEnvVariable("CARDDAV_IMMICH_BDAY_SYNC_CARDDAV_BASIC_USER")
	carddavPass := getRequiredEnvVariable("CARDDAV_IMMICH_BDAY_SYNC_CARDDAV_BASIC_PASS")

	immich := ImmichApi{
		ApiUrl: getRequiredEnvVariable("CARDDAV_IMMICH_BDAY_SYNC_IMMICH_API_URL"),
		ApiKey: getRequiredEnvVariable("CARDDAV_IMMICH_BDAY_SYNC_IMMICH_API_KEY"),
	}

	birthDates := make(map[string]string)

	dec, err := FetchAddressbook(carddavUri, carddavUser, carddavPass)
	if err != nil {
		panic(err)
	}

	for {
		card, err := dec.Decode()
		if err == io.EOF {
			break
		} else if err != nil {
			panic(err)
		}

		name := card.PreferredValue(vcard.FieldFormattedName)
		bday, err := GetBDayInISO8001Format(card)

		if err != nil {
			fmt.Printf("\n[WARN]: %s\n", err.Error())
		} else if len(bday) == 0 { // No birthday available
			continue
		}

		birthDates[name] = bday
	}
	fmt.Printf("Extracted %d Birthdates.\n", len(birthDates))

	allPeopleResponse, err := immich.GetAllPeopleFromImmich()
	if err != nil {
		panic(err)
	}

	personUpdates := []PersonUpdateDto{}

	for _, person := range allPeopleResponse.People {
		bday, exists := birthDates[person.Name]

		if exists && person.BirthDate != bday { // Check if the birthDate even needs to be updated
			personUpdate := PersonUpdateDto{
				Id:        person.Id,
				BirthDate: bday,
			}
			personUpdates = append(personUpdates, personUpdate)

			fmt.Printf("Updating %-25s(%s) with new BDAY %s\n", person.Name, person.Id, bday)
		}
	}

	if len(personUpdates) > 0 {
		fmt.Printf("Updating %d Persons.\n", len(personUpdates))

		err = immich.UpdatePeopleOnImmich(personUpdates)

		if err != nil {
			panic(err)
		}
	} else {
		fmt.Println("No update required.")
	}
}

func getRequiredEnvVariable(name string) string {
	result, exists := os.LookupEnv(name)
	if !exists {
		panic(fmt.Sprintf("ENV variable %s is required", name))
	}

	return result
}
