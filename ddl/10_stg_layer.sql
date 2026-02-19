-- ============================================================
-- Helvetia Insurance DWH + Data Mart
-- Layer: STG_INS (raw landing)
-- ============================================================

CREATE TABLE STG_INS.STG_POLICY (
  stg_policy_id             BIGINT       NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
  source_system_id          VARCHAR(40)  NOT NULL,
  source_policy_id          VARCHAR(80)  NOT NULL,
  policy_number             VARCHAR(50),
  product_code              VARCHAR(40),
  policyholder_id           VARCHAR(80),
  policy_status_code        VARCHAR(20),
  inception_date            DATE,
  expiry_date               DATE,
  source_valid_from         DATE,
  source_valid_to           DATE,
  batch_run_id              BIGINT       NOT NULL,
  source_extract_ts         TIMESTAMP,
  source_file_name          VARCHAR(260),
  row_hash                  CHAR(64),
  ingested_ts               TIMESTAMP    NOT NULL DEFAULT CURRENT TIMESTAMP,
  CONSTRAINT PK_STG_POLICY PRIMARY KEY (stg_policy_id)
);

CREATE TABLE STG_INS.STG_PRODUCT (
  stg_product_id            BIGINT       NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
  source_system_id          VARCHAR(40)  NOT NULL,
  source_product_id         VARCHAR(80)  NOT NULL,
  product_code              VARCHAR(40),
  product_name              VARCHAR(120),
  line_of_business          VARCHAR(50),
  tariff_code               VARCHAR(50),
  source_valid_from         DATE,
  source_valid_to           DATE,
  batch_run_id              BIGINT       NOT NULL,
  source_extract_ts         TIMESTAMP,
  source_file_name          VARCHAR(260),
  row_hash                  CHAR(64),
  ingested_ts               TIMESTAMP    NOT NULL DEFAULT CURRENT TIMESTAMP,
  CONSTRAINT PK_STG_PRODUCT PRIMARY KEY (stg_product_id)
);

CREATE TABLE STG_INS.STG_PARTY (
  stg_party_id              BIGINT       NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
  source_system_id          VARCHAR(40)  NOT NULL,
  source_party_id           VARCHAR(80)  NOT NULL,
  party_type                VARCHAR(20)  NOT NULL,
  full_name                 VARCHAR(160),
  legal_name                VARCHAR(200),
  tax_id                    VARCHAR(40),
  country_code              CHAR(2),
  birth_date                DATE,
  source_valid_from         DATE,
  source_valid_to           DATE,
  batch_run_id              BIGINT       NOT NULL,
  source_extract_ts         TIMESTAMP,
  source_file_name          VARCHAR(260),
  row_hash                  CHAR(64),
  ingested_ts               TIMESTAMP    NOT NULL DEFAULT CURRENT TIMESTAMP,
  CONSTRAINT PK_STG_PARTY PRIMARY KEY (stg_party_id)
);

CREATE TABLE STG_INS.STG_AGENT_RELATION (
  stg_agent_relation_id     BIGINT        NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
  source_system_id          VARCHAR(40)   NOT NULL,
  source_relation_id        VARCHAR(80)   NOT NULL,
  source_agent_id           VARCHAR(80)   NOT NULL,
  source_supervisor_id      VARCHAR(80),
  source_org_unit_id        VARCHAR(80),
  relation_type_code        VARCHAR(30),
  credit_split_percent      DECIMAL(7,4),
  source_valid_from         DATE,
  source_valid_to           DATE,
  batch_run_id              BIGINT        NOT NULL,
  source_extract_ts         TIMESTAMP,
  source_file_name          VARCHAR(260),
  row_hash                  CHAR(64),
  ingested_ts               TIMESTAMP     NOT NULL DEFAULT CURRENT TIMESTAMP,
  CONSTRAINT PK_STG_AGENT_REL PRIMARY KEY (stg_agent_relation_id)
);

CREATE TABLE STG_INS.STG_ORG_UNIT (
  stg_org_unit_id           BIGINT       NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
  source_system_id          VARCHAR(40)  NOT NULL,
  source_org_unit_id        VARCHAR(80)  NOT NULL,
  org_unit_code             VARCHAR(40),
  org_unit_name             VARCHAR(160),
  legal_entity              VARCHAR(120),
  region_code               VARCHAR(40),
  source_valid_from         DATE,
  source_valid_to           DATE,
  batch_run_id              BIGINT       NOT NULL,
  source_extract_ts         TIMESTAMP,
  source_file_name          VARCHAR(260),
  row_hash                  CHAR(64),
  ingested_ts               TIMESTAMP    NOT NULL DEFAULT CURRENT TIMESTAMP,
  CONSTRAINT PK_STG_ORG_UNIT PRIMARY KEY (stg_org_unit_id)
);

CREATE TABLE STG_INS.STG_CHANNEL (
  stg_channel_id            BIGINT       NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
  source_system_id          VARCHAR(40)  NOT NULL,
  source_channel_id         VARCHAR(80)  NOT NULL,
  channel_code              VARCHAR(30),
  channel_name              VARCHAR(80),
  source_valid_from         DATE,
  source_valid_to           DATE,
  batch_run_id              BIGINT       NOT NULL,
  source_extract_ts         TIMESTAMP,
  source_file_name          VARCHAR(260),
  row_hash                  CHAR(64),
  ingested_ts               TIMESTAMP    NOT NULL DEFAULT CURRENT TIMESTAMP,
  CONSTRAINT PK_STG_CHANNEL PRIMARY KEY (stg_channel_id)
);

CREATE TABLE STG_INS.STG_COMMISSION_PLAN (
  stg_commission_plan_id    BIGINT       NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
  source_system_id          VARCHAR(40)  NOT NULL,
  source_plan_id            VARCHAR(80)  NOT NULL,
  plan_code                 VARCHAR(40),
  plan_name                 VARCHAR(120),
  model_type_code           VARCHAR(40),
  source_valid_from         DATE,
  source_valid_to           DATE,
  batch_run_id              BIGINT       NOT NULL,
  source_extract_ts         TIMESTAMP,
  source_file_name          VARCHAR(260),
  row_hash                  CHAR(64),
  ingested_ts               TIMESTAMP    NOT NULL DEFAULT CURRENT TIMESTAMP,
  CONSTRAINT PK_STG_PLAN PRIMARY KEY (stg_commission_plan_id)
);

CREATE TABLE STG_INS.STG_COMMISSION_RULE (
  stg_commission_rule_id    BIGINT        NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
  source_system_id          VARCHAR(40)   NOT NULL,
  source_rule_id            VARCHAR(80)   NOT NULL,
  source_plan_id            VARCHAR(80),
  rule_code                 VARCHAR(40),
  event_type_code           VARCHAR(30),
  base_type_code            VARCHAR(30),
  rule_rate                 DECIMAL(9,6),
  clawback_months           SMALLINT,
  source_valid_from         DATE,
  source_valid_to           DATE,
  batch_run_id              BIGINT        NOT NULL,
  source_extract_ts         TIMESTAMP,
  source_file_name          VARCHAR(260),
  row_hash                  CHAR(64),
  ingested_ts               TIMESTAMP     NOT NULL DEFAULT CURRENT TIMESTAMP,
  CONSTRAINT PK_STG_RULE PRIMARY KEY (stg_commission_rule_id)
);

CREATE TABLE STG_INS.STG_REASON (
  stg_reason_id             BIGINT        NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
  source_system_id          VARCHAR(40)   NOT NULL,
  source_reason_id          VARCHAR(80)   NOT NULL,
  reason_code               VARCHAR(40),
  reason_type_code          VARCHAR(30),
  reason_text               VARCHAR(300),
  source_valid_from         DATE,
  source_valid_to           DATE,
  batch_run_id              BIGINT        NOT NULL,
  source_extract_ts         TIMESTAMP,
  source_file_name          VARCHAR(260),
  row_hash                  CHAR(64),
  ingested_ts               TIMESTAMP     NOT NULL DEFAULT CURRENT TIMESTAMP,
  CONSTRAINT PK_STG_REASON PRIMARY KEY (stg_reason_id)
);

CREATE TABLE STG_INS.STG_PREMIUM_TXN (
  stg_premium_txn_id        BIGINT         NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
  source_system_id          VARCHAR(40)    NOT NULL,
  source_premium_txn_id     VARCHAR(80)    NOT NULL,
  source_policy_id          VARCHAR(80)    NOT NULL,
  premium_event_type        VARCHAR(30),
  booking_date              DATE,
  coverage_start_date       DATE,
  coverage_end_date         DATE,
  posting_period            CHAR(7),
  currency_code             CHAR(3),
  gross_premium_amount      DECIMAL(18,2),
  net_premium_amount        DECIMAL(18,2),
  tax_amount                DECIMAL(18,2),
  batch_run_id              BIGINT         NOT NULL,
  source_extract_ts         TIMESTAMP,
  source_file_name          VARCHAR(260),
  row_hash                  CHAR(64),
  ingested_ts               TIMESTAMP      NOT NULL DEFAULT CURRENT TIMESTAMP,
  CONSTRAINT PK_STG_PREMIUM PRIMARY KEY (stg_premium_txn_id)
);

CREATE TABLE STG_INS.STG_PROVISION_EVENT (
  stg_provision_event_id    BIGINT         NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
  source_system_id          VARCHAR(40)    NOT NULL,
  source_provision_event_id VARCHAR(80)    NOT NULL,
  source_premium_txn_id     VARCHAR(80)    NOT NULL,
  source_policy_id          VARCHAR(80)    NOT NULL,
  source_agent_id           VARCHAR(80),
  source_plan_id            VARCHAR(80),
  source_rule_id            VARCHAR(80),
  source_channel_id         VARCHAR(80),
  source_org_unit_id        VARCHAR(80),
  event_effective_date      DATE,
  accrual_period            CHAR(7),
  currency_code             CHAR(3),
  base_amount               DECIMAL(18,2),
  rate_value                DECIMAL(9,6),
  gross_provision_amount    DECIMAL(18,2),
  clawback_amount           DECIMAL(18,2),
  tax_amount                DECIMAL(18,2),
  net_provision_amount      DECIMAL(18,2),
  reversal_flag             CHAR(1)        DEFAULT 'N',
  batch_run_id              BIGINT         NOT NULL,
  source_extract_ts         TIMESTAMP,
  source_file_name          VARCHAR(260),
  row_hash                  CHAR(64),
  ingested_ts               TIMESTAMP      NOT NULL DEFAULT CURRENT TIMESTAMP,
  CONSTRAINT PK_STG_PROV_EVT PRIMARY KEY (stg_provision_event_id),
  CONSTRAINT CK_STG_PROV_EVT_REV CHECK (reversal_flag IN ('J','N'))
);

CREATE TABLE STG_INS.STG_PAYOUT_EVENT (
  stg_payout_event_id       BIGINT         NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
  source_system_id          VARCHAR(40)    NOT NULL,
  source_payout_id          VARCHAR(80)    NOT NULL,
  source_provision_event_id VARCHAR(80),
  source_agent_id           VARCHAR(80),
  source_org_unit_id        VARCHAR(80),
  payout_date               DATE,
  currency_code             CHAR(3),
  payout_amount             DECIMAL(18,2),
  withholding_tax_amount    DECIMAL(18,2),
  payment_fee_amount        DECIMAL(18,2),
  batch_run_id              BIGINT         NOT NULL,
  source_extract_ts         TIMESTAMP,
  source_file_name          VARCHAR(260),
  row_hash                  CHAR(64),
  ingested_ts               TIMESTAMP      NOT NULL DEFAULT CURRENT TIMESTAMP,
  CONSTRAINT PK_STG_PAYOUT PRIMARY KEY (stg_payout_event_id)
);

CREATE TABLE STG_INS.STG_ADJUSTMENT_EVENT (
  stg_adjustment_event_id   BIGINT         NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
  source_system_id          VARCHAR(40)    NOT NULL,
  source_adjustment_id      VARCHAR(80)    NOT NULL,
  source_provision_event_id VARCHAR(80),
  source_agent_id           VARCHAR(80),
  source_reason_id          VARCHAR(80),
  adjustment_date           DATE,
  currency_code             CHAR(3),
  adjustment_amount         DECIMAL(18,2),
  batch_run_id              BIGINT         NOT NULL,
  source_extract_ts         TIMESTAMP,
  source_file_name          VARCHAR(260),
  row_hash                  CHAR(64),
  ingested_ts               TIMESTAMP      NOT NULL DEFAULT CURRENT TIMESTAMP,
  CONSTRAINT PK_STG_ADJ PRIMARY KEY (stg_adjustment_event_id)
);

CREATE TABLE STG_INS.STG_FX_RATE (
  stg_fx_rate_id            BIGINT         NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
  source_system_id          VARCHAR(40)    NOT NULL,
  rate_date                 DATE           NOT NULL,
  from_currency_code        CHAR(3)        NOT NULL,
  to_currency_code          CHAR(3)        NOT NULL,
  fx_rate                   DECIMAL(18,8)  NOT NULL,
  batch_run_id              BIGINT         NOT NULL,
  source_extract_ts         TIMESTAMP,
  source_file_name          VARCHAR(260),
  row_hash                  CHAR(64),
  ingested_ts               TIMESTAMP      NOT NULL DEFAULT CURRENT TIMESTAMP,
  CONSTRAINT PK_STG_FX PRIMARY KEY (stg_fx_rate_id)
);
