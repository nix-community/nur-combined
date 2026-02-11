# carddav-immich-bday-sync
Sync the birthdays of your contacts on a CardDAV server to your [Immich](https://immich.app/) instance.

The program downloads your contacts and extracts the birthdays.
Then it fetches all of the facial-recognition persons on your Immich instance.
If their names match the name of one of your contacts, their birthday gets set to the contacts birthday.

## How to use
1. You need a CardDAV addressbook containing your contacts. (and a username/password for authentication)
2. You need a running Immich instance. (and an API key)
3. Set the following environment variables:
```Shell
CARDDAV_IMMICH_BDAY_SYNC_CARDDAV_URL=https://contacts.example.com
CARDDAV_IMMICH_BDAY_SYNC_CARDDAV_BASIC_USER=johndoe
CARDDAV_IMMICH_BDAY_SYNC_CARDDAV_BASIC_PASS=correcthorsebatterystaple

CARDDAV_IMMICH_BDAY_SYNC_IMMICH_API_URL=https://img.example.com
CARDDAV_IMMICH_BDAY_SYNC_IMMICH_API_KEY=supersecretkey
```
4. Run the program.