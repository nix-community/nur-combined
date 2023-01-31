CREATE TABLE acmedns(
		Name TEXT,
		Value TEXT
	);
INSERT INTO acmedns VALUES('db_version','1');
CREATE TABLE records(
        Username TEXT UNIQUE NOT NULL PRIMARY KEY,
        Password TEXT UNIQUE NOT NULL,
        Subdomain TEXT UNIQUE NOT NULL,
		AllowFrom TEXT
    );
CREATE TABLE txt(
		Subdomain TEXT NOT NULL,
		Value   TEXT NOT NULL DEFAULT '',
		LastUpdate INT
	);
