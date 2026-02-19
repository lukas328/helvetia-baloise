-- ============================================================
-- Helvetia Insurance DWH + Data Mart
-- Layer: DM_VERSICHERUNG (sales provisioning mart)
-- ============================================================

CREATE TABLE DM_VERSICHERUNG.DIM_DATUM (
  datum_key            INTEGER     NOT NULL,
  datum                DATE        NOT NULL,
  jahr                 SMALLINT    NOT NULL,
  quartal              SMALLINT    NOT NULL,
  monat                SMALLINT    NOT NULL,
  kalenderwoche        SMALLINT    NOT NULL,
  tag_im_monat         SMALLINT    NOT NULL,
  ist_monatsende       CHAR(1)     NOT NULL DEFAULT 'N',
  CONSTRAINT PK_DIM_DATUM PRIMARY KEY (datum_key),
  CONSTRAINT UQ_DIM_DATUM_1 UNIQUE (datum),
  CONSTRAINT CK_DIM_DATUM_1 CHECK (ist_monatsende IN ('J','N'))
);

CREATE TABLE DM_VERSICHERUNG.DIM_WAEHRUNG (
  waehrung_key         CHAR(3)      NOT NULL,
  waehrung_name        VARCHAR(60)  NOT NULL,
  reporting_flag       CHAR(1)      NOT NULL DEFAULT 'N',
  CONSTRAINT PK_DIM_WAEHRUNG PRIMARY KEY (waehrung_key),
  CONSTRAINT CK_DIM_WAEHRUNG_1 CHECK (reporting_flag IN ('J','N'))
);

CREATE TABLE DM_VERSICHERUNG.DIM_ORGANISATIONSEINHEIT (
  organisationseinheit_key   INTEGER      NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
  oe_code                    VARCHAR(40)  NOT NULL,
  oe_name                    VARCHAR(120) NOT NULL,
  rechtseinheit              VARCHAR(120),
  region                     VARCHAR(80),
  CONSTRAINT PK_DIM_OE PRIMARY KEY (organisationseinheit_key),
  CONSTRAINT UQ_DIM_OE_1 UNIQUE (oe_code)
);

CREATE TABLE DM_VERSICHERUNG.DIM_VERTRIEBSKANAL (
  vertriebskanal_key    INTEGER      NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
  kanal_code            VARCHAR(30)  NOT NULL,
  kanal_name            VARCHAR(80)  NOT NULL,
  CONSTRAINT PK_DIM_KANAL PRIMARY KEY (vertriebskanal_key),
  CONSTRAINT UQ_DIM_KANAL_1 UNIQUE (kanal_code)
);

CREATE TABLE DM_VERSICHERUNG.DIM_GRUND (
  grund_key             INTEGER      NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
  grund_code            VARCHAR(40)  NOT NULL,
  grund_typ             VARCHAR(30)  NOT NULL,
  grund_text            VARCHAR(200),
  CONSTRAINT PK_DIM_GRUND PRIMARY KEY (grund_key),
  CONSTRAINT UQ_DIM_GRUND_1 UNIQUE (grund_code)
);

CREATE TABLE DM_VERSICHERUNG.DIM_POLICE (
  police_key            BIGINT       NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
  policenummer          VARCHAR(50)  NOT NULL,
  kundensegment         VARCHAR(50),
  vertragsbeginn        DATE,
  vertragsende          DATE,
  status_code           VARCHAR(20),
  gueltig_von           DATE         NOT NULL,
  gueltig_bis           DATE         NOT NULL DEFAULT DATE('9999-12-31'),
  ist_aktuell           CHAR(1)      NOT NULL DEFAULT 'J',
  CONSTRAINT PK_DIM_POLICE PRIMARY KEY (police_key),
  CONSTRAINT UQ_DIM_POLICE_1 UNIQUE (policenummer, gueltig_von),
  CONSTRAINT CK_DIM_POLICE_1 CHECK (ist_aktuell IN ('J','N'))
);

CREATE TABLE DM_VERSICHERUNG.DIM_PRODUKT (
  produkt_key           BIGINT       NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
  produkt_code          VARCHAR(40)  NOT NULL,
  produkt_name          VARCHAR(120) NOT NULL,
  sparte                VARCHAR(50),
  tarif                 VARCHAR(50),
  gueltig_von           DATE         NOT NULL,
  gueltig_bis           DATE         NOT NULL DEFAULT DATE('9999-12-31'),
  ist_aktuell           CHAR(1)      NOT NULL DEFAULT 'J',
  CONSTRAINT PK_DIM_PRODUKT PRIMARY KEY (produkt_key),
  CONSTRAINT UQ_DIM_PRODUKT_1 UNIQUE (produkt_code, gueltig_von),
  CONSTRAINT CK_DIM_PRODUKT_1 CHECK (ist_aktuell IN ('J','N'))
);

CREATE TABLE DM_VERSICHERUNG.DIM_VERMITTLER (
  vermittler_key        BIGINT       NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
  vermittler_nummer     VARCHAR(40)  NOT NULL,
  vollname              VARCHAR(150) NOT NULL,
  vermittler_typ        VARCHAR(30),
  status_code           VARCHAR(20),
  eintrittsdatum        DATE,
  austrittsdatum        DATE,
  gueltig_von           DATE         NOT NULL,
  gueltig_bis           DATE         NOT NULL DEFAULT DATE('9999-12-31'),
  ist_aktuell           CHAR(1)      NOT NULL DEFAULT 'J',
  CONSTRAINT PK_DIM_VERMITTLER PRIMARY KEY (vermittler_key),
  CONSTRAINT UQ_DIM_VERMITTLER_1 UNIQUE (vermittler_nummer, gueltig_von),
  CONSTRAINT CK_DIM_VERMITTLER_1 CHECK (ist_aktuell IN ('J','N'))
);

CREATE TABLE DM_VERSICHERUNG.DIM_PROVISIONSPLAN (
  provisionsplan_key    BIGINT       NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
  plan_code             VARCHAR(40)  NOT NULL,
  plan_name             VARCHAR(120) NOT NULL,
  provisionsmodell      VARCHAR(40),
  gueltig_von           DATE         NOT NULL,
  gueltig_bis           DATE         NOT NULL DEFAULT DATE('9999-12-31'),
  ist_aktuell           CHAR(1)      NOT NULL DEFAULT 'J',
  CONSTRAINT PK_DIM_PLAN PRIMARY KEY (provisionsplan_key),
  CONSTRAINT UQ_DIM_PLAN_1 UNIQUE (plan_code, gueltig_von),
  CONSTRAINT CK_DIM_PLAN_1 CHECK (ist_aktuell IN ('J','N'))
);

CREATE TABLE DM_VERSICHERUNG.DIM_PROVISIONSREGEL (
  provisionsregel_key   BIGINT       NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
  regel_code            VARCHAR(40)  NOT NULL,
  ereignistyp           VARCHAR(30)  NOT NULL,
  beschreibung          VARCHAR(300),
  clawback_monate       SMALLINT,
  gueltig_von           DATE         NOT NULL,
  gueltig_bis           DATE         NOT NULL DEFAULT DATE('9999-12-31'),
  ist_aktuell           CHAR(1)      NOT NULL DEFAULT 'J',
  CONSTRAINT PK_DIM_REGEL PRIMARY KEY (provisionsregel_key),
  CONSTRAINT UQ_DIM_REGEL_1 UNIQUE (regel_code, gueltig_von),
  CONSTRAINT CK_DIM_REGEL_1 CHECK (ist_aktuell IN ('J','N'))
);

CREATE TABLE DM_VERSICHERUNG.FKT_VERTRIEBSPROVISIONSEREIGNIS (
  provisionsereignis_key      BIGINT         NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
  police_key                  BIGINT         NOT NULL,
  produkt_key                 BIGINT         NOT NULL,
  vermittler_key              BIGINT         NOT NULL,
  vertriebskanal_key          INTEGER        NOT NULL,
  provisionsplan_key          BIGINT         NOT NULL,
  provisionsregel_key         BIGINT         NOT NULL,
  organisationseinheit_key    INTEGER        NOT NULL,
  waehrung_key                CHAR(3)        NOT NULL,
  abgrenzungsdatum_key        INTEGER        NOT NULL,
  buchungsdatum_key           INTEGER        NOT NULL,
  policenummer                VARCHAR(50)    NOT NULL,
  praemientransaktion_id      VARCHAR(64)    NOT NULL,
  quell_system_id             VARCHAR(40)    NOT NULL,
  abrechnungsperiode          CHAR(7)        NOT NULL,
  bruttopraemie_betrag        DECIMAL(18,2)  NOT NULL DEFAULT 0,
  provisionsbasis_betrag      DECIMAL(18,2)  NOT NULL DEFAULT 0,
  provisionssatz              DECIMAL(9,6)   NOT NULL DEFAULT 0,
  brutto_provision_betrag     DECIMAL(18,2)  NOT NULL DEFAULT 0,
  stornohaftung_betrag        DECIMAL(18,2)  NOT NULL DEFAULT 0,
  netto_provision_betrag      DECIMAL(18,2)  NOT NULL DEFAULT 0,
  steuer_betrag               DECIMAL(18,2)  NOT NULL DEFAULT 0,
  fx_kurs                     DECIMAL(18,8)  NOT NULL DEFAULT 1,
  netto_provision_report_ccy  DECIMAL(18,2)  NOT NULL DEFAULT 0,
  ladedatum_ts                TIMESTAMP      NOT NULL DEFAULT CURRENT TIMESTAMP,
  CONSTRAINT PK_FKT_VPE PRIMARY KEY (provisionsereignis_key),
  CONSTRAINT FK_FKT_VPE_POL FOREIGN KEY (police_key) REFERENCES DM_VERSICHERUNG.DIM_POLICE(police_key),
  CONSTRAINT FK_FKT_VPE_PROD FOREIGN KEY (produkt_key) REFERENCES DM_VERSICHERUNG.DIM_PRODUKT(produkt_key),
  CONSTRAINT FK_FKT_VPE_VERM FOREIGN KEY (vermittler_key) REFERENCES DM_VERSICHERUNG.DIM_VERMITTLER(vermittler_key),
  CONSTRAINT FK_FKT_VPE_KANAL FOREIGN KEY (vertriebskanal_key) REFERENCES DM_VERSICHERUNG.DIM_VERTRIEBSKANAL(vertriebskanal_key),
  CONSTRAINT FK_FKT_VPE_PLAN FOREIGN KEY (provisionsplan_key) REFERENCES DM_VERSICHERUNG.DIM_PROVISIONSPLAN(provisionsplan_key),
  CONSTRAINT FK_FKT_VPE_REGEL FOREIGN KEY (provisionsregel_key) REFERENCES DM_VERSICHERUNG.DIM_PROVISIONSREGEL(provisionsregel_key),
  CONSTRAINT FK_FKT_VPE_OE FOREIGN KEY (organisationseinheit_key) REFERENCES DM_VERSICHERUNG.DIM_ORGANISATIONSEINHEIT(organisationseinheit_key),
  CONSTRAINT FK_FKT_VPE_WHR FOREIGN KEY (waehrung_key) REFERENCES DM_VERSICHERUNG.DIM_WAEHRUNG(waehrung_key),
  CONSTRAINT FK_FKT_VPE_DAT1 FOREIGN KEY (abgrenzungsdatum_key) REFERENCES DM_VERSICHERUNG.DIM_DATUM(datum_key),
  CONSTRAINT FK_FKT_VPE_DAT2 FOREIGN KEY (buchungsdatum_key) REFERENCES DM_VERSICHERUNG.DIM_DATUM(datum_key)
);

CREATE TABLE DM_VERSICHERUNG.FKT_PROVISIONSAUSZAHLUNG (
  auszahlung_key              BIGINT         NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
  provisionsereignis_key      BIGINT         NOT NULL,
  vermittler_key              BIGINT         NOT NULL,
  auszahlungsdatum_key        INTEGER        NOT NULL,
  waehrung_key                CHAR(3)        NOT NULL,
  organisationseinheit_key    INTEGER        NOT NULL,
  auszahlung_id               VARCHAR(64)    NOT NULL,
  ausgezahlt_betrag           DECIMAL(18,2)  NOT NULL DEFAULT 0,
  quellensteuer_betrag        DECIMAL(18,2)  NOT NULL DEFAULT 0,
  zahlungsgebuehr_betrag      DECIMAL(18,2)  NOT NULL DEFAULT 0,
  ausgezahlt_report_ccy       DECIMAL(18,2)  NOT NULL DEFAULT 0,
  ladedatum_ts                TIMESTAMP      NOT NULL DEFAULT CURRENT TIMESTAMP,
  CONSTRAINT PK_FKT_AUSZAHL PRIMARY KEY (auszahlung_key),
  CONSTRAINT UQ_FKT_AUSZAHL_1 UNIQUE (auszahlung_id, provisionsereignis_key),
  CONSTRAINT FK_FKT_AUSZAHL_EVT FOREIGN KEY (provisionsereignis_key) REFERENCES DM_VERSICHERUNG.FKT_VERTRIEBSPROVISIONSEREIGNIS(provisionsereignis_key),
  CONSTRAINT FK_FKT_AUSZAHL_VERM FOREIGN KEY (vermittler_key) REFERENCES DM_VERSICHERUNG.DIM_VERMITTLER(vermittler_key),
  CONSTRAINT FK_FKT_AUSZAHL_DAT FOREIGN KEY (auszahlungsdatum_key) REFERENCES DM_VERSICHERUNG.DIM_DATUM(datum_key),
  CONSTRAINT FK_FKT_AUSZAHL_WHR FOREIGN KEY (waehrung_key) REFERENCES DM_VERSICHERUNG.DIM_WAEHRUNG(waehrung_key),
  CONSTRAINT FK_FKT_AUSZAHL_OE FOREIGN KEY (organisationseinheit_key) REFERENCES DM_VERSICHERUNG.DIM_ORGANISATIONSEINHEIT(organisationseinheit_key)
);

CREATE TABLE DM_VERSICHERUNG.FKT_PROVISIONSANPASSUNG (
  anpassung_key               BIGINT         NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
  provisionsereignis_key      BIGINT         NOT NULL,
  vermittler_key              BIGINT         NOT NULL,
  anpassungsdatum_key         INTEGER        NOT NULL,
  grund_key                   INTEGER        NOT NULL,
  waehrung_key                CHAR(3)        NOT NULL,
  anpassung_id                VARCHAR(64)    NOT NULL,
  anpassung_betrag            DECIMAL(18,2)  NOT NULL DEFAULT 0,
  anpassung_report_ccy        DECIMAL(18,2)  NOT NULL DEFAULT 0,
  ladedatum_ts                TIMESTAMP      NOT NULL DEFAULT CURRENT TIMESTAMP,
  CONSTRAINT PK_FKT_ANPASS PRIMARY KEY (anpassung_key),
  CONSTRAINT UQ_FKT_ANPASS_1 UNIQUE (anpassung_id),
  CONSTRAINT FK_FKT_ANPASS_EVT FOREIGN KEY (provisionsereignis_key) REFERENCES DM_VERSICHERUNG.FKT_VERTRIEBSPROVISIONSEREIGNIS(provisionsereignis_key),
  CONSTRAINT FK_FKT_ANPASS_VERM FOREIGN KEY (vermittler_key) REFERENCES DM_VERSICHERUNG.DIM_VERMITTLER(vermittler_key),
  CONSTRAINT FK_FKT_ANPASS_DAT FOREIGN KEY (anpassungsdatum_key) REFERENCES DM_VERSICHERUNG.DIM_DATUM(datum_key),
  CONSTRAINT FK_FKT_ANPASS_GRUND FOREIGN KEY (grund_key) REFERENCES DM_VERSICHERUNG.DIM_GRUND(grund_key),
  CONSTRAINT FK_FKT_ANPASS_WHR FOREIGN KEY (waehrung_key) REFERENCES DM_VERSICHERUNG.DIM_WAEHRUNG(waehrung_key)
);

CREATE TABLE DM_VERSICHERUNG.BR_POLICE_VERMITTLER_AUFTEILUNG (
  police_key                  BIGINT        NOT NULL,
  vermittler_key              BIGINT        NOT NULL,
  gueltig_von                 DATE          NOT NULL,
  gueltig_bis                 DATE          NOT NULL DEFAULT DATE('9999-12-31'),
  aufteilungsquote_prozent    DECIMAL(5,2)  NOT NULL,
  bezugsrolle                 VARCHAR(40),
  CONSTRAINT PK_BR_POL_VERM PRIMARY KEY (police_key, vermittler_key, gueltig_von),
  CONSTRAINT CK_BR_POL_VERM_1 CHECK (aufteilungsquote_prozent > 0 AND aufteilungsquote_prozent <= 100),
  CONSTRAINT FK_BR_POL_VERM_POL FOREIGN KEY (police_key) REFERENCES DM_VERSICHERUNG.DIM_POLICE(police_key),
  CONSTRAINT FK_BR_POL_VERM_VERM FOREIGN KEY (vermittler_key) REFERENCES DM_VERSICHERUNG.DIM_VERMITTLER(vermittler_key)
);

CREATE TABLE DM_VERSICHERUNG.BR_VERMITTLER_HIERARCHIE (
  unterstellter_vermittler_key  BIGINT    NOT NULL,
  vorgesetzter_vermittler_key   BIGINT    NOT NULL,
  gueltig_von                   DATE      NOT NULL,
  gueltig_bis                   DATE      NOT NULL DEFAULT DATE('9999-12-31'),
  ebene                         SMALLINT  NOT NULL,
  CONSTRAINT PK_BR_HIER PRIMARY KEY (unterstellter_vermittler_key, vorgesetzter_vermittler_key, gueltig_von),
  CONSTRAINT CK_BR_HIER_1 CHECK (unterstellter_vermittler_key <> vorgesetzter_vermittler_key),
  CONSTRAINT FK_BR_HIER_U FOREIGN KEY (unterstellter_vermittler_key) REFERENCES DM_VERSICHERUNG.DIM_VERMITTLER(vermittler_key),
  CONSTRAINT FK_BR_HIER_V FOREIGN KEY (vorgesetzter_vermittler_key) REFERENCES DM_VERSICHERUNG.DIM_VERMITTLER(vermittler_key)
);

CREATE INDEX DM_VERSICHERUNG.IX_FKT_VPE_1 ON DM_VERSICHERUNG.FKT_VERTRIEBSPROVISIONSEREIGNIS (abgrenzungsdatum_key);
CREATE INDEX DM_VERSICHERUNG.IX_FKT_VPE_2 ON DM_VERSICHERUNG.FKT_VERTRIEBSPROVISIONSEREIGNIS (vermittler_key, abgrenzungsdatum_key);
CREATE INDEX DM_VERSICHERUNG.IX_FKT_VPE_3 ON DM_VERSICHERUNG.FKT_VERTRIEBSPROVISIONSEREIGNIS (police_key, buchungsdatum_key);
CREATE INDEX DM_VERSICHERUNG.IX_FKT_AUSZAHL_1 ON DM_VERSICHERUNG.FKT_PROVISIONSAUSZAHLUNG (auszahlungsdatum_key, vermittler_key);
CREATE INDEX DM_VERSICHERUNG.IX_FKT_ANPASS_1 ON DM_VERSICHERUNG.FKT_PROVISIONSANPASSUNG (anpassungsdatum_key, vermittler_key);
