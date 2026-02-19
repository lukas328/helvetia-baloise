-- ============================================================
-- Helvetia Insurance DWH + Data Mart
-- Layer: DWH_CORE (generic, mart-independent)
-- ============================================================

CREATE TABLE DWH_CORE.CORE_DATE (
  date_key                   INTEGER      NOT NULL,
  calendar_date              DATE         NOT NULL,
  year_num                   SMALLINT     NOT NULL,
  quarter_num                SMALLINT     NOT NULL,
  month_num                  SMALLINT     NOT NULL,
  week_num                   SMALLINT     NOT NULL,
  day_num                    SMALLINT     NOT NULL,
  is_month_end               CHAR(1)      NOT NULL DEFAULT 'N',
  CONSTRAINT PK_CORE_DATE PRIMARY KEY (date_key),
  CONSTRAINT UQ_CORE_DATE_1 UNIQUE (calendar_date),
  CONSTRAINT CK_CORE_DATE_1 CHECK (is_month_end IN ('J','N'))
);

CREATE TABLE DWH_CORE.CORE_CURRENCY (
  currency_key               CHAR(3)       NOT NULL,
  currency_name              VARCHAR(60)   NOT NULL,
  is_reporting_currency      CHAR(1)       NOT NULL DEFAULT 'N',
  valid_from                 DATE          NOT NULL,
  valid_to                   DATE          NOT NULL DEFAULT DATE('9999-12-31'),
  CONSTRAINT PK_CORE_CURRENCY PRIMARY KEY (currency_key),
  CONSTRAINT CK_CORE_CURRENCY_1 CHECK (is_reporting_currency IN ('J','N'))
);

CREATE TABLE DWH_CORE.CORE_ORG_UNIT (
  org_unit_key               BIGINT        NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
  source_system_id           VARCHAR(40)   NOT NULL,
  source_org_unit_id         VARCHAR(80)   NOT NULL,
  org_unit_code              VARCHAR(40),
  org_unit_name              VARCHAR(160),
  legal_entity               VARCHAR(120),
  region_code                VARCHAR(40),
  valid_from                 DATE          NOT NULL,
  valid_to                   DATE          NOT NULL DEFAULT DATE('9999-12-31'),
  is_current                 CHAR(1)       NOT NULL DEFAULT 'J',
  CONSTRAINT PK_CORE_ORG_UNIT PRIMARY KEY (org_unit_key),
  CONSTRAINT UQ_CORE_ORG_UNIT_1 UNIQUE (source_system_id, source_org_unit_id, valid_from),
  CONSTRAINT CK_CORE_ORG_UNIT_1 CHECK (is_current IN ('J','N'))
);

CREATE TABLE DWH_CORE.CORE_CHANNEL (
  channel_key                BIGINT        NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
  source_system_id           VARCHAR(40)   NOT NULL,
  source_channel_id          VARCHAR(80)   NOT NULL,
  channel_code               VARCHAR(30),
  channel_name               VARCHAR(80),
  valid_from                 DATE          NOT NULL,
  valid_to                   DATE          NOT NULL DEFAULT DATE('9999-12-31'),
  is_current                 CHAR(1)       NOT NULL DEFAULT 'J',
  CONSTRAINT PK_CORE_CHANNEL PRIMARY KEY (channel_key),
  CONSTRAINT UQ_CORE_CHANNEL_1 UNIQUE (source_system_id, source_channel_id, valid_from),
  CONSTRAINT CK_CORE_CHANNEL_1 CHECK (is_current IN ('J','N'))
);

CREATE TABLE DWH_CORE.CORE_REASON (
  reason_key                 BIGINT        NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
  source_system_id           VARCHAR(40)   NOT NULL,
  source_reason_id           VARCHAR(80)   NOT NULL,
  reason_code                VARCHAR(40),
  reason_type_code           VARCHAR(30),
  reason_text                VARCHAR(300),
  valid_from                 DATE          NOT NULL,
  valid_to                   DATE          NOT NULL DEFAULT DATE('9999-12-31'),
  is_current                 CHAR(1)       NOT NULL DEFAULT 'J',
  CONSTRAINT PK_CORE_REASON PRIMARY KEY (reason_key),
  CONSTRAINT UQ_CORE_REASON_1 UNIQUE (source_system_id, source_reason_id, valid_from),
  CONSTRAINT CK_CORE_REASON_1 CHECK (is_current IN ('J','N'))
);

CREATE TABLE DWH_CORE.CORE_PARTY (
  party_key                  BIGINT        NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
  source_system_id           VARCHAR(40)   NOT NULL,
  source_party_id            VARCHAR(80)   NOT NULL,
  party_type                 VARCHAR(20)   NOT NULL,
  full_name                  VARCHAR(160),
  legal_name                 VARCHAR(200),
  tax_id                     VARCHAR(40),
  country_code               CHAR(2),
  birth_date                 DATE,
  valid_from                 DATE          NOT NULL,
  valid_to                   DATE          NOT NULL DEFAULT DATE('9999-12-31'),
  is_current                 CHAR(1)       NOT NULL DEFAULT 'J',
  CONSTRAINT PK_CORE_PARTY PRIMARY KEY (party_key),
  CONSTRAINT UQ_CORE_PARTY_1 UNIQUE (source_system_id, source_party_id, valid_from),
  CONSTRAINT CK_CORE_PARTY_1 CHECK (is_current IN ('J','N'))
);

CREATE TABLE DWH_CORE.CORE_PARTY_ROLE (
  party_role_key             BIGINT        NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
  party_key                  BIGINT        NOT NULL,
  role_type_code             VARCHAR(30)   NOT NULL,
  role_identifier            VARCHAR(80),
  valid_from                 DATE          NOT NULL,
  valid_to                   DATE          NOT NULL DEFAULT DATE('9999-12-31'),
  is_current                 CHAR(1)       NOT NULL DEFAULT 'J',
  CONSTRAINT PK_CORE_PARTY_ROLE PRIMARY KEY (party_role_key),
  CONSTRAINT UQ_CORE_PARTY_ROLE_1 UNIQUE (party_key, role_type_code, valid_from),
  CONSTRAINT CK_CORE_PARTY_ROLE_1 CHECK (is_current IN ('J','N')),
  CONSTRAINT FK_CORE_PARTY_ROLE_1 FOREIGN KEY (party_key) REFERENCES DWH_CORE.CORE_PARTY(party_key)
);

CREATE TABLE DWH_CORE.CORE_PRODUCT (
  product_key                BIGINT        NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
  source_system_id           VARCHAR(40)   NOT NULL,
  source_product_id          VARCHAR(80)   NOT NULL,
  product_code               VARCHAR(40),
  product_name               VARCHAR(120),
  line_of_business           VARCHAR(50),
  tariff_code                VARCHAR(50),
  valid_from                 DATE          NOT NULL,
  valid_to                   DATE          NOT NULL DEFAULT DATE('9999-12-31'),
  is_current                 CHAR(1)       NOT NULL DEFAULT 'J',
  CONSTRAINT PK_CORE_PRODUCT PRIMARY KEY (product_key),
  CONSTRAINT UQ_CORE_PRODUCT_1 UNIQUE (source_system_id, source_product_id, valid_from),
  CONSTRAINT CK_CORE_PRODUCT_1 CHECK (is_current IN ('J','N'))
);

CREATE TABLE DWH_CORE.CORE_POLICY (
  policy_key                 BIGINT        NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
  source_system_id           VARCHAR(40)   NOT NULL,
  source_policy_id           VARCHAR(80)   NOT NULL,
  policy_number              VARCHAR(50)   NOT NULL,
  policyholder_party_key     BIGINT,
  product_key                BIGINT,
  policy_status_code         VARCHAR(20),
  inception_date             DATE,
  expiry_date                DATE,
  valid_from                 DATE          NOT NULL,
  valid_to                   DATE          NOT NULL DEFAULT DATE('9999-12-31'),
  is_current                 CHAR(1)       NOT NULL DEFAULT 'J',
  CONSTRAINT PK_CORE_POLICY PRIMARY KEY (policy_key),
  CONSTRAINT UQ_CORE_POLICY_1 UNIQUE (source_system_id, source_policy_id, valid_from),
  CONSTRAINT CK_CORE_POLICY_1 CHECK (is_current IN ('J','N')),
  CONSTRAINT FK_CORE_POLICY_PARTY FOREIGN KEY (policyholder_party_key) REFERENCES DWH_CORE.CORE_PARTY(party_key),
  CONSTRAINT FK_CORE_POLICY_PRODUCT FOREIGN KEY (product_key) REFERENCES DWH_CORE.CORE_PRODUCT(product_key)
);

CREATE TABLE DWH_CORE.CORE_POLICY_AGENT_ASSIGNMENT (
  policy_agent_assignment_key BIGINT       NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
  policy_key                  BIGINT       NOT NULL,
  agent_party_role_key        BIGINT       NOT NULL,
  supervisor_party_role_key   BIGINT,
  org_unit_key                BIGINT,
  channel_key                 BIGINT,
  assignment_type_code        VARCHAR(30),
  credit_split_percent        DECIMAL(7,4) NOT NULL,
  valid_from                  DATE         NOT NULL,
  valid_to                    DATE         NOT NULL DEFAULT DATE('9999-12-31'),
  CONSTRAINT PK_CORE_POL_AGENT PRIMARY KEY (policy_agent_assignment_key),
  CONSTRAINT UQ_CORE_POL_AGENT_1 UNIQUE (policy_key, agent_party_role_key, valid_from),
  CONSTRAINT CK_CORE_POL_AGENT_1 CHECK (credit_split_percent > 0 AND credit_split_percent <= 100),
  CONSTRAINT FK_CORE_POL_AGENT_1 FOREIGN KEY (policy_key) REFERENCES DWH_CORE.CORE_POLICY(policy_key),
  CONSTRAINT FK_CORE_POL_AGENT_2 FOREIGN KEY (agent_party_role_key) REFERENCES DWH_CORE.CORE_PARTY_ROLE(party_role_key),
  CONSTRAINT FK_CORE_POL_AGENT_3 FOREIGN KEY (supervisor_party_role_key) REFERENCES DWH_CORE.CORE_PARTY_ROLE(party_role_key),
  CONSTRAINT FK_CORE_POL_AGENT_4 FOREIGN KEY (org_unit_key) REFERENCES DWH_CORE.CORE_ORG_UNIT(org_unit_key),
  CONSTRAINT FK_CORE_POL_AGENT_5 FOREIGN KEY (channel_key) REFERENCES DWH_CORE.CORE_CHANNEL(channel_key)
);

CREATE TABLE DWH_CORE.CORE_COMMISSION_PLAN (
  commission_plan_key        BIGINT        NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
  source_system_id           VARCHAR(40)   NOT NULL,
  source_plan_id             VARCHAR(80)   NOT NULL,
  plan_code                  VARCHAR(40),
  plan_name                  VARCHAR(120),
  model_type_code            VARCHAR(40),
  valid_from                 DATE          NOT NULL,
  valid_to                   DATE          NOT NULL DEFAULT DATE('9999-12-31'),
  is_current                 CHAR(1)       NOT NULL DEFAULT 'J',
  CONSTRAINT PK_CORE_PLAN PRIMARY KEY (commission_plan_key),
  CONSTRAINT UQ_CORE_PLAN_1 UNIQUE (source_system_id, source_plan_id, valid_from),
  CONSTRAINT CK_CORE_PLAN_1 CHECK (is_current IN ('J','N'))
);

CREATE TABLE DWH_CORE.CORE_COMMISSION_RULE (
  commission_rule_key        BIGINT        NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
  source_system_id           VARCHAR(40)   NOT NULL,
  source_rule_id             VARCHAR(80)   NOT NULL,
  commission_plan_key        BIGINT,
  rule_code                  VARCHAR(40),
  event_type_code            VARCHAR(30),
  base_type_code             VARCHAR(30),
  rule_rate                  DECIMAL(9,6),
  clawback_months            SMALLINT,
  valid_from                 DATE          NOT NULL,
  valid_to                   DATE          NOT NULL DEFAULT DATE('9999-12-31'),
  is_current                 CHAR(1)       NOT NULL DEFAULT 'J',
  CONSTRAINT PK_CORE_RULE PRIMARY KEY (commission_rule_key),
  CONSTRAINT UQ_CORE_RULE_1 UNIQUE (source_system_id, source_rule_id, valid_from),
  CONSTRAINT CK_CORE_RULE_1 CHECK (is_current IN ('J','N')),
  CONSTRAINT FK_CORE_RULE_1 FOREIGN KEY (commission_plan_key) REFERENCES DWH_CORE.CORE_COMMISSION_PLAN(commission_plan_key)
);

CREATE TABLE DWH_CORE.CORE_FX_RATE (
  fx_rate_key                BIGINT         NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
  source_system_id           VARCHAR(40)    NOT NULL,
  rate_date_key              INTEGER        NOT NULL,
  from_currency_key          CHAR(3)        NOT NULL,
  to_currency_key            CHAR(3)        NOT NULL,
  fx_rate                    DECIMAL(18,8)  NOT NULL,
  batch_run_id               BIGINT         NOT NULL,
  loaded_ts                  TIMESTAMP      NOT NULL DEFAULT CURRENT TIMESTAMP,
  CONSTRAINT PK_CORE_FX PRIMARY KEY (fx_rate_key),
  CONSTRAINT UQ_CORE_FX_1 UNIQUE (source_system_id, rate_date_key, from_currency_key, to_currency_key),
  CONSTRAINT FK_CORE_FX_DATE FOREIGN KEY (rate_date_key) REFERENCES DWH_CORE.CORE_DATE(date_key),
  CONSTRAINT FK_CORE_FX_CUR1 FOREIGN KEY (from_currency_key) REFERENCES DWH_CORE.CORE_CURRENCY(currency_key),
  CONSTRAINT FK_CORE_FX_CUR2 FOREIGN KEY (to_currency_key) REFERENCES DWH_CORE.CORE_CURRENCY(currency_key)
);

CREATE TABLE DWH_CORE.CORE_PREMIUM_TRANSACTION (
  premium_txn_key            BIGINT         NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
  source_system_id           VARCHAR(40)    NOT NULL,
  source_premium_txn_id      VARCHAR(80)    NOT NULL,
  policy_key                 BIGINT         NOT NULL,
  transaction_type_code      VARCHAR(30),
  booking_date_key           INTEGER,
  coverage_start_date_key    INTEGER,
  coverage_end_date_key      INTEGER,
  accounting_period          CHAR(7),
  currency_key               CHAR(3),
  gross_amount               DECIMAL(18,2),
  net_amount                 DECIMAL(18,2),
  tax_amount                 DECIMAL(18,2),
  source_event_ts            TIMESTAMP,
  batch_run_id               BIGINT         NOT NULL,
  loaded_ts                  TIMESTAMP      NOT NULL DEFAULT CURRENT TIMESTAMP,
  CONSTRAINT PK_CORE_PREMIUM_TXN PRIMARY KEY (premium_txn_key),
  CONSTRAINT UQ_CORE_PREMIUM_TXN_1 UNIQUE (source_system_id, source_premium_txn_id),
  CONSTRAINT FK_CORE_PREMIUM_TXN_1 FOREIGN KEY (policy_key) REFERENCES DWH_CORE.CORE_POLICY(policy_key),
  CONSTRAINT FK_CORE_PREMIUM_TXN_2 FOREIGN KEY (booking_date_key) REFERENCES DWH_CORE.CORE_DATE(date_key),
  CONSTRAINT FK_CORE_PREMIUM_TXN_3 FOREIGN KEY (coverage_start_date_key) REFERENCES DWH_CORE.CORE_DATE(date_key),
  CONSTRAINT FK_CORE_PREMIUM_TXN_4 FOREIGN KEY (coverage_end_date_key) REFERENCES DWH_CORE.CORE_DATE(date_key),
  CONSTRAINT FK_CORE_PREMIUM_TXN_5 FOREIGN KEY (currency_key) REFERENCES DWH_CORE.CORE_CURRENCY(currency_key)
);

CREATE TABLE DWH_CORE.CORE_PROVISION_TRANSACTION (
  provision_txn_key          BIGINT         NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
  source_system_id           VARCHAR(40)    NOT NULL,
  source_provision_event_id  VARCHAR(80)    NOT NULL,
  premium_txn_key            BIGINT         NOT NULL,
  policy_key                 BIGINT         NOT NULL,
  agent_party_role_key       BIGINT,
  commission_plan_key        BIGINT,
  commission_rule_key        BIGINT,
  org_unit_key               BIGINT,
  channel_key                BIGINT,
  event_effective_date_key   INTEGER,
  accrual_period             CHAR(7),
  currency_key               CHAR(3),
  provision_base_amount      DECIMAL(18,2),
  provision_rate             DECIMAL(9,6),
  gross_provision_amount     DECIMAL(18,2),
  clawback_amount            DECIMAL(18,2),
  tax_amount                 DECIMAL(18,2),
  net_provision_amount       DECIMAL(18,2),
  reversal_flag              CHAR(1)        NOT NULL DEFAULT 'N',
  batch_run_id               BIGINT         NOT NULL,
  loaded_ts                  TIMESTAMP      NOT NULL DEFAULT CURRENT TIMESTAMP,
  CONSTRAINT PK_CORE_PROV_TXN PRIMARY KEY (provision_txn_key),
  CONSTRAINT UQ_CORE_PROV_TXN_1 UNIQUE (source_system_id, source_provision_event_id),
  CONSTRAINT CK_CORE_PROV_TXN_1 CHECK (reversal_flag IN ('J','N')),
  CONSTRAINT FK_CORE_PROV_TXN_1 FOREIGN KEY (premium_txn_key) REFERENCES DWH_CORE.CORE_PREMIUM_TRANSACTION(premium_txn_key),
  CONSTRAINT FK_CORE_PROV_TXN_2 FOREIGN KEY (policy_key) REFERENCES DWH_CORE.CORE_POLICY(policy_key),
  CONSTRAINT FK_CORE_PROV_TXN_3 FOREIGN KEY (agent_party_role_key) REFERENCES DWH_CORE.CORE_PARTY_ROLE(party_role_key),
  CONSTRAINT FK_CORE_PROV_TXN_4 FOREIGN KEY (commission_plan_key) REFERENCES DWH_CORE.CORE_COMMISSION_PLAN(commission_plan_key),
  CONSTRAINT FK_CORE_PROV_TXN_5 FOREIGN KEY (commission_rule_key) REFERENCES DWH_CORE.CORE_COMMISSION_RULE(commission_rule_key),
  CONSTRAINT FK_CORE_PROV_TXN_6 FOREIGN KEY (org_unit_key) REFERENCES DWH_CORE.CORE_ORG_UNIT(org_unit_key),
  CONSTRAINT FK_CORE_PROV_TXN_7 FOREIGN KEY (channel_key) REFERENCES DWH_CORE.CORE_CHANNEL(channel_key),
  CONSTRAINT FK_CORE_PROV_TXN_8 FOREIGN KEY (event_effective_date_key) REFERENCES DWH_CORE.CORE_DATE(date_key),
  CONSTRAINT FK_CORE_PROV_TXN_9 FOREIGN KEY (currency_key) REFERENCES DWH_CORE.CORE_CURRENCY(currency_key)
);

CREATE TABLE DWH_CORE.CORE_PAYOUT_TRANSACTION (
  payout_txn_key             BIGINT         NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
  source_system_id           VARCHAR(40)    NOT NULL,
  source_payout_id           VARCHAR(80)    NOT NULL,
  provision_txn_key          BIGINT,
  agent_party_role_key       BIGINT,
  org_unit_key               BIGINT,
  payout_date_key            INTEGER,
  currency_key               CHAR(3),
  payout_amount              DECIMAL(18,2),
  withholding_tax_amount     DECIMAL(18,2),
  payment_fee_amount         DECIMAL(18,2),
  batch_run_id               BIGINT         NOT NULL,
  loaded_ts                  TIMESTAMP      NOT NULL DEFAULT CURRENT TIMESTAMP,
  CONSTRAINT PK_CORE_PAYOUT_TXN PRIMARY KEY (payout_txn_key),
  CONSTRAINT UQ_CORE_PAYOUT_TXN_1 UNIQUE (source_system_id, source_payout_id),
  CONSTRAINT FK_CORE_PAYOUT_TXN_1 FOREIGN KEY (provision_txn_key) REFERENCES DWH_CORE.CORE_PROVISION_TRANSACTION(provision_txn_key),
  CONSTRAINT FK_CORE_PAYOUT_TXN_2 FOREIGN KEY (agent_party_role_key) REFERENCES DWH_CORE.CORE_PARTY_ROLE(party_role_key),
  CONSTRAINT FK_CORE_PAYOUT_TXN_3 FOREIGN KEY (org_unit_key) REFERENCES DWH_CORE.CORE_ORG_UNIT(org_unit_key),
  CONSTRAINT FK_CORE_PAYOUT_TXN_4 FOREIGN KEY (payout_date_key) REFERENCES DWH_CORE.CORE_DATE(date_key),
  CONSTRAINT FK_CORE_PAYOUT_TXN_5 FOREIGN KEY (currency_key) REFERENCES DWH_CORE.CORE_CURRENCY(currency_key)
);

CREATE TABLE DWH_CORE.CORE_ADJUSTMENT_TRANSACTION (
  adjustment_txn_key         BIGINT         NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
  source_system_id           VARCHAR(40)    NOT NULL,
  source_adjustment_id       VARCHAR(80)    NOT NULL,
  provision_txn_key          BIGINT,
  agent_party_role_key       BIGINT,
  reason_key                 BIGINT,
  adjustment_date_key        INTEGER,
  currency_key               CHAR(3),
  adjustment_amount          DECIMAL(18,2),
  batch_run_id               BIGINT         NOT NULL,
  loaded_ts                  TIMESTAMP      NOT NULL DEFAULT CURRENT TIMESTAMP,
  CONSTRAINT PK_CORE_ADJ_TXN PRIMARY KEY (adjustment_txn_key),
  CONSTRAINT UQ_CORE_ADJ_TXN_1 UNIQUE (source_system_id, source_adjustment_id),
  CONSTRAINT FK_CORE_ADJ_TXN_1 FOREIGN KEY (provision_txn_key) REFERENCES DWH_CORE.CORE_PROVISION_TRANSACTION(provision_txn_key),
  CONSTRAINT FK_CORE_ADJ_TXN_2 FOREIGN KEY (agent_party_role_key) REFERENCES DWH_CORE.CORE_PARTY_ROLE(party_role_key),
  CONSTRAINT FK_CORE_ADJ_TXN_3 FOREIGN KEY (reason_key) REFERENCES DWH_CORE.CORE_REASON(reason_key),
  CONSTRAINT FK_CORE_ADJ_TXN_4 FOREIGN KEY (adjustment_date_key) REFERENCES DWH_CORE.CORE_DATE(date_key),
  CONSTRAINT FK_CORE_ADJ_TXN_5 FOREIGN KEY (currency_key) REFERENCES DWH_CORE.CORE_CURRENCY(currency_key)
);

CREATE TABLE DWH_CORE.CORE_RECORD_LINEAGE (
  lineage_key                BIGINT         NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
  entity_name                VARCHAR(60)    NOT NULL,
  record_business_key        VARCHAR(200)   NOT NULL,
  source_system_id           VARCHAR(40)    NOT NULL,
  source_business_key        VARCHAR(200),
  batch_run_id               BIGINT         NOT NULL,
  source_extract_ts          TIMESTAMP,
  loaded_ts                  TIMESTAMP      NOT NULL DEFAULT CURRENT TIMESTAMP,
  CONSTRAINT PK_CORE_LINEAGE PRIMARY KEY (lineage_key)
);

CREATE INDEX DWH_CORE.IX_CORE_POLICY_1 ON DWH_CORE.CORE_POLICY (policy_number, valid_from);
CREATE INDEX DWH_CORE.IX_CORE_PREMIUM_TXN_1 ON DWH_CORE.CORE_PREMIUM_TRANSACTION (booking_date_key, policy_key);
CREATE INDEX DWH_CORE.IX_CORE_PROV_TXN_1 ON DWH_CORE.CORE_PROVISION_TRANSACTION (event_effective_date_key, agent_party_role_key);
CREATE INDEX DWH_CORE.IX_CORE_PROV_TXN_2 ON DWH_CORE.CORE_PROVISION_TRANSACTION (policy_key, accrual_period);
CREATE INDEX DWH_CORE.IX_CORE_PAYOUT_TXN_1 ON DWH_CORE.CORE_PAYOUT_TRANSACTION (payout_date_key, agent_party_role_key);
CREATE INDEX DWH_CORE.IX_CORE_ADJ_TXN_1 ON DWH_CORE.CORE_ADJUSTMENT_TRANSACTION (adjustment_date_key, agent_party_role_key);
