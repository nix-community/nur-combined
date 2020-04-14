{ fetchurl }:

{ id, ... } @ args:

(fetchurl ({
  url = "https://drive.google.com/uc?export=download&id=${id}";
} // removeAttrs args [ "id" ]))
