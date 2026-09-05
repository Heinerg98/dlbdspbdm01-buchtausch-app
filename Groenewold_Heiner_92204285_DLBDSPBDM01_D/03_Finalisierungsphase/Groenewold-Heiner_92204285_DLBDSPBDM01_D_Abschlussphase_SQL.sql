-- =====================================================================
-- Buchtausch-App -- Phase 3 (Finalisierungsphase)
-- =====================================================================

PRAGMA foreign_keys = ON;


-- #####################################################################
-- ALLE TABELLEN ERSTELLEN
-- #####################################################################

CREATE TABLE ADRESSE (
    adresse_id INTEGER PRIMARY KEY AUTOINCREMENT,
    strasse    TEXT NOT NULL,
    hausnummer TEXT NOT NULL,
    plz        TEXT NOT NULL,
    ort        TEXT NOT NULL
);

CREATE TABLE BENUTZER (
    benutzer_id INTEGER PRIMARY KEY AUTOINCREMENT,
    adresse_id  INTEGER NOT NULL,
    vorname     TEXT NOT NULL,
    nachname    TEXT NOT NULL,
    email       TEXT NOT NULL UNIQUE,
    telefon     TEXT,
    FOREIGN KEY (adresse_id) REFERENCES ADRESSE(adresse_id)
);

CREATE TABLE AUTOR (
    autor_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name     TEXT NOT NULL
);

CREATE TABLE VERLAG (
    verlag_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name      TEXT NOT NULL
);

CREATE TABLE GENRE (
    genre_id    INTEGER PRIMARY KEY AUTOINCREMENT,
    bezeichnung TEXT NOT NULL
);

CREATE TABLE SPRACHE (
    sprache_id  INTEGER PRIMARY KEY AUTOINCREMENT,
    bezeichnung TEXT NOT NULL
);

CREATE TABLE STANDORT (
    standort_id  INTEGER PRIMARY KEY AUTOINCREMENT,
    bezeichnung  TEXT NOT NULL,
    strasse      TEXT NOT NULL,
    hausnummer   TEXT NOT NULL,
    plz          TEXT NOT NULL,
    ort          TEXT NOT NULL,
    breitengrad  REAL NOT NULL,
    laengengrad  REAL NOT NULL
);

CREATE TABLE BUCH (
    buch_id                INTEGER PRIMARY KEY AUTOINCREMENT,
    verlag_id              INTEGER NOT NULL,
    genre_id               INTEGER NOT NULL,
    sprache_id             INTEGER NOT NULL,
    titel                  TEXT NOT NULL,
    veroeffentlichungsjahr INTEGER,
    FOREIGN KEY (verlag_id)  REFERENCES VERLAG(verlag_id),
    FOREIGN KEY (genre_id)   REFERENCES GENRE(genre_id),
    FOREIGN KEY (sprache_id) REFERENCES SPRACHE(sprache_id)
);

CREATE TABLE BUCH_AUTOR (
    buch_id  INTEGER NOT NULL,
    autor_id INTEGER NOT NULL,
    PRIMARY KEY (buch_id, autor_id),
    FOREIGN KEY (buch_id)  REFERENCES BUCH(buch_id),
    FOREIGN KEY (autor_id) REFERENCES AUTOR(autor_id)
);

CREATE TABLE BUCHEXEMPLAR (
    buchexemplar_id INTEGER PRIMARY KEY AUTOINCREMENT,
    buch_id         INTEGER NOT NULL,
    benutzer_id     INTEGER NOT NULL,
    zustand         TEXT NOT NULL,
    buchstatus      TEXT NOT NULL CHECK (buchstatus IN ('verfuegbar','verliehen','inaktiv')),
    FOREIGN KEY (buch_id)     REFERENCES BUCH(buch_id),
    FOREIGN KEY (benutzer_id) REFERENCES BENUTZER(benutzer_id)
);

CREATE TABLE ANGEBOT (
    angebot_id             INTEGER PRIMARY KEY AUTOINCREMENT,
    buchexemplar_id        INTEGER NOT NULL,
    leihdauer_tage         INTEGER NOT NULL CHECK (leihdauer_tage > 0),
    versand_moeglich       INTEGER NOT NULL CHECK (versand_moeglich IN (0,1)),
    verfuegbarkeitsstatus  TEXT NOT NULL CHECK (verfuegbarkeitsstatus IN ('verfuegbar','verliehen','inaktiv')),
    erstellt_am            DATE NOT NULL,
    aktiv                  INTEGER NOT NULL CHECK (aktiv IN (0,1)),
    FOREIGN KEY (buchexemplar_id) REFERENCES BUCHEXEMPLAR(buchexemplar_id)
);

CREATE TABLE ZEITSLOT (
    zeitslot_id INTEGER PRIMARY KEY AUTOINCREMENT,
    angebot_id  INTEGER NOT NULL,
    beginn      DATETIME NOT NULL,
    ende        DATETIME NOT NULL,
    status      TEXT NOT NULL CHECK (status IN ('frei','gebucht')),
    FOREIGN KEY (angebot_id) REFERENCES ANGEBOT(angebot_id),
    CHECK (beginn < ende)
);

CREATE TABLE UEBERGABEOPTION (
    uebergabeoption_id INTEGER PRIMARY KEY AUTOINCREMENT,
    angebot_id         INTEGER NOT NULL,
    standort_id        INTEGER NOT NULL,
    zeitslot_id        INTEGER NOT NULL,
    FOREIGN KEY (angebot_id)  REFERENCES ANGEBOT(angebot_id),
    FOREIGN KEY (standort_id) REFERENCES STANDORT(standort_id),
    FOREIGN KEY (zeitslot_id) REFERENCES ZEITSLOT(zeitslot_id)
);

CREATE TABLE AUSLEIHVORGANG (
    ausleihe_id                    INTEGER PRIMARY KEY AUTOINCREMENT,
    angebot_id                     INTEGER NOT NULL,
    benutzer_id                    INTEGER NOT NULL,
    uebergabeoption_id             INTEGER NOT NULL,
    ausleihbeginn                  DATE NOT NULL,
    geplantes_rueckgabedatum       DATE,
    tatsaechliches_rueckgabedatum  DATE,
    bearbeitungsstatus             TEXT NOT NULL CHECK (bearbeitungsstatus IN ('laufend','abgeschlossen')),
    FOREIGN KEY (angebot_id)         REFERENCES ANGEBOT(angebot_id),
    FOREIGN KEY (benutzer_id)        REFERENCES BENUTZER(benutzer_id),
    FOREIGN KEY (uebergabeoption_id) REFERENCES UEBERGABEOPTION(uebergabeoption_id),
    CHECK (geplantes_rueckgabedatum IS NULL OR geplantes_rueckgabedatum > ausleihbeginn),
    CHECK (tatsaechliches_rueckgabedatum IS NULL OR tatsaechliches_rueckgabedatum >= ausleihbeginn)
);

CREATE TABLE BEWERTUNG (
    bewertung_id    INTEGER PRIMARY KEY AUTOINCREMENT,
    ausleihe_id     INTEGER NOT NULL,
    benutzer_id     INTEGER NOT NULL,
    buchexemplar_id INTEGER NOT NULL,
    sterne          INTEGER NOT NULL CHECK (sterne BETWEEN 1 AND 5),
    kommentar       TEXT,
    erstellt_am     DATE NOT NULL,
    FOREIGN KEY (ausleihe_id)      REFERENCES AUSLEIHVORGANG(ausleihe_id),
    FOREIGN KEY (benutzer_id)      REFERENCES BENUTZER(benutzer_id),
    FOREIGN KEY (buchexemplar_id)  REFERENCES BUCHEXEMPLAR(buchexemplar_id)
);


-- #####################################################################
-- STAMMDATEN BEFUELLEN
-- Adresse, Benutzer, Autor, Verlag, Genre, Sprache, Standort
-- #####################################################################

INSERT INTO ADRESSE (strasse, hausnummer, plz, ort) VALUES
('Bahnhofstraße','12','26382','Wilhelmshaven'),
('Marktstraße','5','26389','Wilhelmshaven'),
('Gökerstraße','88','26384','Wilhelmshaven'),
('Peterstraße','21','26386','Wilhelmshaven'),
('Freiligrathstraße','9','26385','Wilhelmshaven'),
('Mühlenweg','3','26388','Wilhelmshaven'),
('Rheinstraße','45','26382','Wilhelmshaven'),
('Virchowstraße','17','26389','Wilhelmshaven'),
('Adalbertstraße','60','26386','Wilhelmshaven'),
('Kieler Straße','30','26384','Wilhelmshaven');

INSERT INTO BENUTZER (adresse_id, vorname, nachname, email, telefon) VALUES
(1,'Anna','Schmidt','anna.schmidt@mail.de','04421-111111'),
(2,'Ben','Meyer','ben.meyer@mail.de','04421-222222'),
(3,'Clara','Fischer','clara.fischer@mail.de','04421-333333'),
(4,'David','Wagner','david.wagner@mail.de','04421-444444'),
(5,'Emma','Becker','emma.becker@mail.de','04421-555555'),
(6,'Finn','Hoffmann','finn.hoffmann@mail.de','04421-666666'),
(7,'Greta','Schulz','greta.schulz@mail.de','04421-777777'),
(8,'Hannes','Koch','hannes.koch@mail.de','04421-888888'),
(9,'Ida','Richter','ida.richter@mail.de','04421-999999'),
(10,'Jonas','Klein','jonas.klein@mail.de','04421-101010');

INSERT INTO AUTOR (name) VALUES
('Franz Kafka'),('Agatha Christie'),('J.K. Rowling'),('Stephen King'),
('Isabel Allende'),('Haruki Murakami'),('Herman Hesse'),('Margaret Atwood'),
('George Orwell'),('Cornelia Funke');

INSERT INTO VERLAG (name) VALUES
('Rowohlt'),('Fischer Verlag'),('Suhrkamp'),('dtv'),('Piper Verlag'),
('Diogenes'),('Hanser Verlag'),('Klett-Cotta'),('Ullstein'),('Beltz & Gelberg');

INSERT INTO GENRE (bezeichnung) VALUES
('Krimi'),('Fantasy'),('Sachbuch'),('Roman'),('Biografie'),
('Thriller'),('Kinderbuch'),('Kochbuch'),('Reisebericht'),('Science-Fiction');

INSERT INTO SPRACHE (bezeichnung) VALUES
('Deutsch'),('Englisch'),('Französisch'),('Spanisch'),('Italienisch'),
('Niederländisch'),('Portugiesisch'),('Russisch'),('Schwedisch'),('Polnisch');

INSERT INTO STANDORT (bezeichnung, strasse, hausnummer, plz, ort, breitengrad, laengengrad) VALUES
('Cafe Lesestoff','Bahnhofstraße','10','26382','Wilhelmshaven',53.5273,8.1103),
('Stadtbibliothek','Rathausplatz','2','26382','Wilhelmshaven',53.5231,8.1135),
('Wochenmarkt Neuende','Neuender Straße','15','26386','Wilhelmshaven',53.5424,8.0847),
('Buchcafe Süd','Peterstraße','25','26386','Wilhelmshaven',53.5388,8.0921),
('Nordseepassage','Marktstraße','50','26389','Wilhelmshaven',53.5265,8.1057),
('Quartierstreff West','Mühlenweg','8','26388','Wilhelmshaven',53.5157,8.0754),
('Hafenpromenade','Rheinstraße','1','26382','Wilhelmshaven',53.5311,8.1198),
('Bürgerhaus Fedderwardergroden','Virchowstraße','20','26389','Wilhelmshaven',53.5442,8.1329),
('Kirchplatz Bant','Adalbertstraße','65','26386','Wilhelmshaven',53.5395,8.0965),
('Bahnhofsvorplatz','Kieler Straße','33','26384','Wilhelmshaven',53.5278,8.1109);


-- #####################################################################
-- BUCH-, AUTOR- UND EXEMPLARDATEN
-- #####################################################################

INSERT INTO BUCH (verlag_id, genre_id, sprache_id, titel, veroeffentlichungsjahr) VALUES
(3,4,1,'Die Verwandlung',1915),
(1,1,1,'Mord im Orientexpress',1934),
(4,2,2,'Harry Potter und der Stein der Weisen',1997),
(5,6,1,'Es',1986),
(6,4,1,'Das Geisterhaus',1982),
(3,4,2,'Kafka am Strand',2002),
(7,4,1,'Der Steppenwolf',1927),
(8,10,2,'Der Report der Magd',1985),
(9,10,1,'1984',1949),
(10,7,1,'Tintenherz',2003),
(2,4,1,'Novellen zweier Welten',2015);

INSERT INTO BUCH_AUTOR (buch_id, autor_id) VALUES
(1,1),(2,2),(3,3),(4,4),(5,5),(6,6),(7,7),(8,8),(9,9),(10,10),
(11,5),(11,7);

INSERT INTO BUCHEXEMPLAR (buch_id, benutzer_id, zustand, buchstatus) VALUES
(1,1,'gut','verfuegbar'),
(2,2,'sehr gut','verfuegbar'),
(3,3,'gebraucht','verliehen'),
(4,4,'gut','verfuegbar'),
(5,5,'neuwertig','verfuegbar'),
(6,6,'gut','verfuegbar'),
(7,7,'gebraucht','verfuegbar'),
(8,8,'sehr gut','verliehen'),
(9,9,'gut','verfuegbar'),
(10,10,'neuwertig','verfuegbar'),
(11,1,'gut','verfuegbar');

INSERT INTO ANGEBOT (buchexemplar_id, leihdauer_tage, versand_moeglich, verfuegbarkeitsstatus, erstellt_am, aktiv) VALUES
(1,14,0,'verfuegbar','2026-01-05',1),
(2,21,1,'verfuegbar','2026-01-10',1),
(3,14,0,'verliehen','2026-01-12',1),
(4,10,1,'verfuegbar','2026-02-01',1),
(5,30,0,'verfuegbar','2026-02-05',1),
(6,14,1,'verfuegbar','2026-02-10',1),
(7,21,0,'verfuegbar','2026-02-15',1),
(8,14,1,'verliehen','2026-03-01',1),
(9,10,0,'verfuegbar','2026-03-05',1),
(10,14,1,'verfuegbar','2026-03-10',1),
(11,20,1,'verfuegbar','2026-03-15',1);

INSERT INTO ZEITSLOT (angebot_id, beginn, ende, status) VALUES
(1,'2026-08-20 10:00','2026-08-20 12:00','frei'),
(2,'2026-08-21 14:00','2026-08-21 16:00','gebucht'),
(3,'2026-08-18 09:00','2026-08-18 11:00','gebucht'),
(4,'2026-08-22 15:00','2026-08-22 17:00','frei'),
(5,'2026-08-23 10:00','2026-08-23 12:00','frei'),
(6,'2026-08-24 13:00','2026-08-24 15:00','frei'),
(7,'2026-08-25 16:00','2026-08-25 18:00','frei'),
(8,'2026-08-15 09:00','2026-08-15 11:00','gebucht'),
(9,'2026-08-26 10:00','2026-08-26 12:00','frei'),
(10,'2026-08-27 14:00','2026-08-27 16:00','frei'),
(11,'2026-08-28 10:00','2026-08-28 12:00','frei');


-- #####################################################################
-- TRANSAKTIONS- UND BEZIEHUNGSDATEN (Dreifachbeziehungen)
-- #####################################################################

INSERT INTO UEBERGABEOPTION (angebot_id, standort_id, zeitslot_id) VALUES
(1,1,1),(2,2,2),(3,3,3),(4,4,4),(5,5,5),
(6,6,6),(7,7,7),(8,8,8),(9,9,9),(10,10,10),
(11,1,11);

INSERT INTO AUSLEIHVORGANG (angebot_id, benutzer_id, uebergabeoption_id, ausleihbeginn, geplantes_rueckgabedatum, tatsaechliches_rueckgabedatum, bearbeitungsstatus) VALUES
(3,4,3,'2026-08-18','2026-08-25','2026-08-24','abgeschlossen'),
(8,1,8,'2026-08-15','2026-08-22','2026-08-21','abgeschlossen'),
(1,2,1,'2026-07-01','2026-07-08','2026-07-07','abgeschlossen'),
(2,3,2,'2026-07-05','2026-07-15','2026-07-14','abgeschlossen'),
(4,5,4,'2026-07-10','2026-07-17','2026-07-16','abgeschlossen'),
(5,6,5,'2026-07-15','2026-07-25','2026-07-24','abgeschlossen'),
(6,7,6,'2026-07-20','2026-07-27','2026-07-26','abgeschlossen'),
(7,8,7,'2026-07-25','2026-08-01','2026-07-31','abgeschlossen'),
(9,10,9,'2026-08-01','2026-08-08','2026-08-07','abgeschlossen'),
(10,1,10,'2026-08-05','2026-08-12','2026-08-11','abgeschlossen');

INSERT INTO BEWERTUNG (ausleihe_id, benutzer_id, buchexemplar_id, sterne, kommentar, erstellt_am) VALUES
(1,4,3,5,'Sehr guter Zustand, schnelle Übergabe.','2026-08-24'),
(2,1,8,4,'Buch war wie beschrieben.','2026-08-21'),
(3,2,1,5,'Toller Klassiker, gerne wieder.','2026-07-07'),
(4,3,2,4,'Spannend, kleine Gebrauchsspuren.','2026-07-14'),
(5,5,4,3,'Buch okay, Übergabe hat sich verzögert.','2026-07-16'),
(6,6,5,5,'Perfekter Zustand, freundlicher Kontakt.','2026-07-24'),
(7,7,6,4,'Gute Erfahrung, Buch pünktlich zurückgegeben.','2026-07-26'),
(8,8,7,5,'Sehr empfehlenswert.','2026-07-31'),
(9,10,9,2,'Buch stärker abgenutzt als angegeben.','2026-08-07'),
(10,1,10,5,'Reibungslose Ausleihe.','2026-08-11');


-- #####################################################################
-- NEGATIVTESTS ZU DEN NEUEN CONSTRAINTS (auskommentiert)
-- #####################################################################

-- Verstoss gegen leihdauer_tage > 0:
-- INSERT INTO ANGEBOT (buchexemplar_id, leihdauer_tage, versand_moeglich, verfuegbarkeitsstatus, erstellt_am, aktiv)
-- VALUES (1, 0, 0, 'verfuegbar', '2026-09-04', 1);

-- Verstoss gegen beginn < ende:
-- INSERT INTO ZEITSLOT (angebot_id, beginn, ende, status)
-- VALUES (1, '2026-09-10 12:00', '2026-09-10 10:00', 'frei');

-- Verstoss gegen tatsaechliches_rueckgabedatum >= ausleihbeginn:
-- INSERT INTO AUSLEIHVORGANG (angebot_id, benutzer_id, uebergabeoption_id, ausleihbeginn, geplantes_rueckgabedatum, tatsaechliches_rueckgabedatum, bearbeitungsstatus)
-- VALUES (1, 2, 1, '2026-09-10', '2026-09-17', '2026-09-01', 'abgeschlossen');


-- #####################################################################
-- TESTFAELLE JE ENTITAET
-- #####################################################################

-- Testfall ADRESSE
SELECT * FROM ADRESSE;

-- Testfall BENUTZER
SELECT * FROM BENUTZER;

-- Testfall AUTOR
SELECT * FROM AUTOR;

-- Testfall VERLAG
SELECT * FROM VERLAG;

-- Testfall GENRE
SELECT * FROM GENRE;

-- Testfall SPRACHE
SELECT * FROM SPRACHE;

-- Testfall STANDORT
SELECT * FROM STANDORT;

-- Testfall BUCH (mit Genre und Sprache)
SELECT b.buch_id, b.titel, g.bezeichnung AS genre, s.bezeichnung AS sprache, b.veroeffentlichungsjahr
FROM BUCH b
JOIN GENRE g ON b.genre_id = g.genre_id
JOIN SPRACHE s ON b.sprache_id = s.sprache_id;

-- Testfall BUCH_AUTOR (Autor:innen je Buch)
SELECT b.buch_id, b.titel, GROUP_CONCAT(a.name, ', ') AS autoren
FROM BUCH b
JOIN BUCH_AUTOR ba ON b.buch_id = ba.buch_id
JOIN AUTOR a ON ba.autor_id = a.autor_id
GROUP BY b.buch_id, b.titel;

-- Testfall BUCHEXEMPLAR (mit Buch und Besitzer)
SELECT be.buchexemplar_id, b.titel, ben.vorname || ' ' || ben.nachname AS besitzer,
       be.zustand, be.buchstatus
FROM BUCHEXEMPLAR be
JOIN BUCH b ON be.buch_id = b.buch_id
JOIN BENUTZER ben ON be.benutzer_id = ben.benutzer_id;

-- Testfall ANGEBOT (verfuegbare Angebote mit Anbieter)
SELECT an.angebot_id, b.titel, ben.vorname || ' ' || ben.nachname AS anbieter,
       an.leihdauer_tage, an.versand_moeglich
FROM ANGEBOT an
JOIN BUCHEXEMPLAR be ON an.buchexemplar_id = be.buchexemplar_id
JOIN BUCH b ON be.buch_id = b.buch_id
JOIN BENUTZER ben ON be.benutzer_id = ben.benutzer_id
WHERE an.verfuegbarkeitsstatus = 'verfuegbar';

-- Testfall ZEITSLOT
SELECT z.zeitslot_id, b.titel, z.beginn, z.ende, z.status
FROM ZEITSLOT z
JOIN ANGEBOT an ON z.angebot_id = an.angebot_id
JOIN BUCHEXEMPLAR be ON an.buchexemplar_id = be.buchexemplar_id
JOIN BUCH b ON be.buch_id = b.buch_id;

-- Testfall UEBERGABEOPTION (Dreifachbeziehung 1)
SELECT u.uebergabeoption_id, b.titel, st.bezeichnung AS standort,
       z.beginn, z.ende
FROM UEBERGABEOPTION u
JOIN ANGEBOT an ON u.angebot_id = an.angebot_id
JOIN BUCHEXEMPLAR be ON an.buchexemplar_id = be.buchexemplar_id
JOIN BUCH b ON be.buch_id = b.buch_id
JOIN STANDORT st ON u.standort_id = st.standort_id
JOIN ZEITSLOT z ON u.zeitslot_id = z.zeitslot_id;

-- Testfall AUSLEIHVORGANG (Dreifachbeziehung 2)
SELECT av.ausleihe_id, b.titel, ben.vorname || ' ' || ben.nachname AS ausleiher,
       av.ausleihbeginn, av.tatsaechliches_rueckgabedatum, av.bearbeitungsstatus
FROM AUSLEIHVORGANG av
JOIN ANGEBOT an ON av.angebot_id = an.angebot_id
JOIN BUCHEXEMPLAR be ON an.buchexemplar_id = be.buchexemplar_id
JOIN BUCH b ON be.buch_id = b.buch_id
JOIN BENUTZER ben ON av.benutzer_id = ben.benutzer_id;

-- Testfall BEWERTUNG (Dreifachbeziehung 3)
SELECT bw.bewertung_id, b.titel, ben.vorname || ' ' || ben.nachname AS bewertender,
       bw.sterne, bw.kommentar, bw.erstellt_am
FROM BEWERTUNG bw
JOIN BUCHEXEMPLAR be ON bw.buchexemplar_id = be.buchexemplar_id
JOIN BUCH b ON be.buch_id = b.buch_id
JOIN BENUTZER ben ON bw.benutzer_id = ben.benutzer_id;


-- #####################################################################
-- KOMPLEXE TESTABFRAGEN
-- #####################################################################

-- Vollstaendige Ausleihhistorie mit Bewertung (Join ueber mehrere Tabellen)
SELECT av.ausleihe_id, b.titel, bw.sterne, bw.kommentar, bw.erstellt_am
FROM AUSLEIHVORGANG av
JOIN ANGEBOT an ON av.angebot_id = an.angebot_id
JOIN BUCHEXEMPLAR be ON an.buchexemplar_id = be.buchexemplar_id
JOIN BUCH b ON be.buch_id = b.buch_id
JOIN BEWERTUNG bw ON av.ausleihe_id = bw.ausleihe_id;

-- Pruefung Geschaeftsregel: kein Angebot darf mehrfach aktiv verliehen sein
SELECT angebot_id, COUNT(*) AS anzahl_laufender_ausleihen
FROM AUSLEIHVORGANG
WHERE bearbeitungsstatus = 'laufend'
GROUP BY angebot_id
HAVING COUNT(*) > 1;

-- Raeumliche Umkreissuche: verfuegbare Angebote im Umkreis von 3 km um
-- den Hauptbahnhof Wilhelmshaven (53.5273 / 8.1103), Haversine-Formel
SELECT *
FROM (
    SELECT an.angebot_id,
           b.titel,
           st.bezeichnung AS standort,
           st.breitengrad,
           st.laengengrad,
           ROUND(
               6371 * acos(
                   cos(radians(53.5273)) * cos(radians(st.breitengrad))
                   * cos(radians(st.laengengrad) - radians(8.1103))
                   + sin(radians(53.5273)) * sin(radians(st.breitengrad))
               ), 2
           ) AS entfernung_km
    FROM ANGEBOT an
    JOIN BUCHEXEMPLAR be ON an.buchexemplar_id = be.buchexemplar_id
    JOIN BUCH b ON be.buch_id = b.buch_id
    JOIN UEBERGABEOPTION u ON u.angebot_id = an.angebot_id
    JOIN STANDORT st ON u.standort_id = st.standort_id
    WHERE an.verfuegbarkeitsstatus = 'verfuegbar'
) AS umkreis
WHERE entfernung_km <= 3
ORDER BY entfernung_km;
