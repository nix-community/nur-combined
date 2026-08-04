package main

import (
	"bytes"
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
)

// https://immich.app/docs/api/introduction/
type ImmichApi struct {
	ApiUrl string
	ApiKey string
}

type Person struct {
	Id        string `json:"id"`
	Name      string `json:"name"`
	BirthDate string `json:"birthDate"`
}

type PersonUpdateDto struct {
	Id        string `json:"id"`
	BirthDate string `json:"birthDate"`
}

type GetAllPeopleResponse struct {
	HasNextPage bool     `json:"hasNextPage"`
	Hidden      int      `json:"hidden"`
	People      []Person `json:"people"`
	Total       int      `json:"total"`
}

type UpdatePeopleRequest struct {
	People []PersonUpdateDto `json:"people"`
}

type PersonUpdateResult struct {
	Id      string  `json:"id"`
	Error   *string `json:"error"`
	Success bool    `json:"success"`
}

// https://immich.app/docs/api/get-all-people
func (immich *ImmichApi) GetAllPeopleFromImmich() (*GetAllPeopleResponse, error) {
	req, err := http.NewRequest(http.MethodGet, immich.ApiUrl+"/people", nil)
	if err != nil {
		return nil, err
	}

	req.Header.Add("Accept", "application/json")
	req.Header.Add("x-api-key", immich.ApiKey)

	res, err := http.DefaultClient.Do(req)
	if err != nil {
		return nil, err
	}

	if res.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("got status %d: %s", res.StatusCode, res.Status)
	}

	dec := json.NewDecoder(res.Body)

	dataRes := GetAllPeopleResponse{}

	err = dec.Decode(&dataRes)
	if err != nil {
		return nil, err
	}

	return &dataRes, nil
}

func (immich *ImmichApi) UpdatePeopleOnImmich(updates []PersonUpdateDto) error {
	data, err := json.MarshalIndent(UpdatePeopleRequest{People: updates}, "", "  ")
	if err != nil {
		return err
	}

	req, err := http.NewRequest(http.MethodPut, immich.ApiUrl+"/people", bytes.NewReader(data))
	if err != nil {
		return err
	}

	req.Header.Add("Accept", "application/json")
	req.Header.Add("Content-Type", "application/json")
	req.Header.Add("x-api-key", immich.ApiKey)

	res, err := http.DefaultClient.Do(req)
	if err != nil {
		return err
	}

	if res.StatusCode != http.StatusOK {
		return fmt.Errorf("got status %d: %s", res.StatusCode, res.Status)
	}

	dec := json.NewDecoder(res.Body)
	results := make([]PersonUpdateResult, len(updates))
	dec.Decode(&results)

	errorMsg := "failed to update one/multiple persons:\n"
	success := true

	for _, result := range results {
		if !result.Success {
			success = false
			errorMsg += fmt.Sprintf("- Person with ID %s: %s", result.Id, *result.Error)
		}
	}

	if !success {
		return errors.New(errorMsg)
	} else {
		return nil
	}
}
