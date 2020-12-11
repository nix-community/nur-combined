{ fetchurl }:

{ um, ... } @ args:

(
  fetchurl (
    {
      url = "https://yandex.ru/maps/export/usermaps/${um}";
    } // removeAttrs args [ "um" ]
  )
)
