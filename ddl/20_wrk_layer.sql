-- ============================================================
-- Helvetia Insurance DWH + Data Mart
-- Layer: WRK_INS (integration/work)
-- ============================================================

CREATE TABLE WRK_INS.WRK_POLICY (
  wrk_policy_id              BIGINT       NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
  source_system_id           VARCHAR(40)  NOT NULL,
  source_policy_id           VARCHAR(80)  NOT NULL,
  policy_number              VARCHAR(50)  NOT NULL,
  product_code               VARCHAR(40),
  policyholder_bk            VARCHAR(80),
  policy_status_code         VARCHAR(20),
  valid_from                 DATE         NOT NULL,
  valid_to                   DATE         NOT NULL DEFAULT DATE('9999-12-31'),
  dq_status                  VARCHAR(10)  NOT NULL DEFAULT 'PASS',
  batch_run_id               BIGINT       NOT NULL,
  transformed_ts             TIMESTAMP    NOT NULL DEFAULT CURRENT TIMESTAMP,
  CONSTRAINT PK_WRK_POLICY PRIMARY KEY (wrk_policy_id),
  CONSTRAINT UQ_WRK_POLICY_1 UNIQUE (source_system_id, source_policy_id, valid_from)
);

CREATE TABLE WRK_INS.WRK_PRODUCT (
  wrk_product_id             BIGINT       NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
  source_system_id           VARCHAR(40)  NOT NULL,
  source_product_id          VARCHAR(80)  NOT NULL,
  product_code               VARCHAR(40)  NOT NULL,
  product_name               VARCHAR(120),
  line_of_business           VARCHAR(50),
  tariff_code                VARCHAR(50),
  valid_from                 DATE         NOT NULL,
  valid_to                   DATE         NOT NULL DEFAULT DATE('9999-12-31'),
  dq_status                  VARCHAR(10)  NOT NULL DEFAULT 'PASS',
  batch_run_id               BIGINT       NOT NULL,
  transformed_ts             TIMESTAMP    NOT NULL DEFAULT CURRENT TIMESTAMP,
  CONSTRAINT PK_WRK_PRODUCT PRIMARY KEY (wrk_product_id),
  CONSTRAINT UQ_WRK_PRODUCT_1 UNIQUE (source_system_id, source_product_id, valid_from)
);

CREATE TABLE WRK_INS.WRK_PARTY (
  wrk_party_id               BIGINT       NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
  source_system_id           VARCHAR(40)  NOT NULL,
  source_party_id            VARCHAR(80)  NOT NULL,
  party_type                 VARCHAR(20)  NOT NULL,
  full_name                  VARCHAR(160),
  legal_name                 VARCHAR(200),
  tax_id                     VARCHAR(40),
  country_code               CHAR(2),
  valid_from                 DATE         NOT NULL,
  valid_to                   DATE         NOT NULL DEFAULT DATE('9999-12-31'),
  dq_status                  VARCHAR(10)  NOT NULL DEFAULT 'PASS',
  batch_run_id               BIGINT       NOT NULL,
  transformed_ts             TIMESTAMP    NOT NULL DEFAULT CURRENT TIMESTAMP,
  CONSTRAINT PK_WRK_PARTY PRIMARY KEY (wrk_party_id),
  CONSTRAINT UQ_WRK_PARTY_1 UNIQUE (source_system_id, source_party_id, valid_from)
);

CREATE TABLE WRK_INS.WRK_AGENT_RELATION (
  wrk_agent_relation_id      BIGINT        NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
  source_system_id           VARCHAR(40)   NOT NULL,
  source_relation_id         VARCHAR(80)   NOT NULL,
  source_agent_id            VARCHAR(80)   NOT NULL,
  source_supervisor_id       VARCHAR(80),
  source_org_unit_id         VARCHAR(80),
  relation_type_code         VARCHAR(30),
  credit_split_percent       DECIMAL(7,4),
  valid_from                 DATE          NOT NULL,
  valid_to                   DATE          NOT NULL DEFAULT DATE('9999-12-31'),
  dq_status                  VARCHAR(10)   NOT NULL DEFAULT 'PASS',
  batch_run_id               BIGINT        NOT NULL,
  transformed_ts             TIMESTAMP     NOT NULL DEFAULT CURRENT TIMESTAMP,
  CONSTRAINT PK_WRK_AGENT_REL PRIMARY KEY (wrk_agent_relation_id),
  CONSTRAINT UQ_WRK_AGENT_REL_1 UNIQUE (source_system_id, source_relation_id, valid_from)
);

CREATE TABLE WRK_INS.WRK_REFERENCE (
  wrk_reference_id           BIGINT        NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
  source_system_id           VARCHAR(40)   NOT NULL,
  ref_domain                 VARCHAR(30)   NOT NULL,
  source_ref_id              VARCHAR(80)   NOT NULL,
  ref_code                   VARCHAR(40)   NOT NULL,
  ref_name                   VARCHAR(160),
  valid_from                 DATE          NOT NULL,
  valid_to                   DATE          NOT NULL DEFAULT DATE('9999-12-31'),
  batch_run_id               BIGINT        NOT NULL,
  transformed_ts             TIMESTAMP     NOT NULL DEFAULT CURRENT TIMESTAMP,
  CONSTRAINT PK_WRK_REF PRIMARY KEY (wrk_reference_id),
  CONSTRAINT UQ_WRK_REF_1 UNIQUE (source_system_id, ref_domain, source_ref_id, valid_from)
);

CREATE TABLE WRK_INS.WRK_PREMIUM_TXN (
  wrk_premium_txn_id         BIGINT         NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
  source_system_id           VARCHAR(40)    NOT NULL,
  source_premium_txn_id      VARCHAR(80)    NOT NULL,
  source_policy_id           VARCHAR(80)    NOT NULL,
  premium_event_type         VARCHAR(30),
  booking_date               DATE,
  coverage_start_date        DATE,
  coverage_end_date          DATE,
  posting_period             CHAR(7),
  currency_code              CHAR(3),
  gross_premium_amount       DECIMAL(18,2),
  net_premium_amount         DECIMAL(18,2),
  tax_amount                 DECIMAL(18,2),
  dq_status                  VARCHAR(10)    NOT NULL DEFAULT 'PASS',
  batch_run_id               BIGINT         NOT NULL,
  transformed_ts             TIMESTAMP      NOT NULL DEFAULT CURRENT TIMESTAMP,
  CONSTRAINT PK_WRK_PREMIUM PRIMARY KEY (wrk_premium_txn_id),
  CONSTRAINT UQ_WRK_PREMIUM_1 UNIQUE (source_system_id, source_premium_txn_id)
);

CREATE TABLE WRK_INS.WRK_PROVISION_EVENT (
  wrk_provision_event_id     BIGINT         NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
  source_system_id           VARCHAR(40)    NOT NULL,
  source_provision_event_id  VARCHAR(80)    NOT NULL,
  source_premium_txn_id      VARCHAR(80)    NOT NULL,
  source_policy_id           VARCHAR(80)    NOT NULL,
  source_agent_id            VARCHAR(80),
  source_plan_id             VARCHAR(80),
  source_rule_id             VARCHAR(80),
  source_channel_id          VARCHAR(80),
  source_org_unit_id         VARCHAR(80),
  event_effective_date       DATE,
  accrual_period             CHAR(7),
  currency_code              CHAR(3),
  base_amount                DECIMAL(18,2),
  rate_value                 DECIMAL(9,6),
  gross_provision_amount     DECIMAL(18,2),
  clawback_amount            DECIMAL(18,2),
  tax_amount                 DECIMAL(18,2),
  net_provision_amount       DECIMAL(18,2),
  reversal_flag              CHAR(1)        NOT NULL DEFAULT 'N',
  dq_status                  VARCHAR(10)    NOT NULL DEFAULT 'PASS',
  batch_run_id               BIGINT         NOT NULL,
  transformed_ts             TIMESTAMP      NOT NULL DEFAULT CURRENT TIMESTAMP,
  CONSTRAINT PK_WRK_PROV_EVT PRIMARY KEY (wrk_provision_event_id),
  CONSTRAINT UQ_WRK_PROV_EVT_1 UNIQUE (source_system_id, source_provision_event_id),
  CONSTRAINT CK_WRK_PROV_EVT_REV CHECK (reversal_flag IN ('J','N'))
);

CREATE TABLE WRK_INS.WRK_PAYOUT_EVENT (
  wrk_payout_event_id        BIGINT         NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
  source_system_id           VARCHAR(40)    NOT NULL,
  source_payout_id           VARCHAR(80)    NOT NULL,
  source_provision_event_id  VARCHAR(80),
  source_agent_id            VARCHAR(80),
  source_org_unit_id         VARCHAR(80),
  payout_date                DATE,
  currency_code              CHAR(3),
  payout_amount              DECIMAL(18,2),
  withholding_tax_amount     DECIMAL(18,2),
  payment_fee_amount         DECIMAL(18,2),
  dq_status                  VARCHAR(10)    NOT NULL DEFAULT 'PASS',
  batch_run_id               BIGINT         NOT NULL,
  transformed_ts             TIMESTAMP      NOT NULL DEFAULT CURRENT TIMESTAMP,
  CONSTRAINT PK_WRK_PAYOUT PRIMARY KEY (wrk_payout_event_id),
  CONSTRAINT UQ_WRK_PAYOUT_1 UNIQUE (source_system_id, source_payout_id)
);

CREATE TABLE WRK_INS.WRK_ADJUSTMENT_EVENT (
  wrk_adjustment_event_id    BIGINT         NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
  source_system_id           VARCHAR(40)    NOT NULL,
  source_adjustment_id       VARCHAR(80)    NOT NULL,
  source_provision_event_id  VARCHAR(80),
  source_agent_id            VARCHAR(80),
  source_reason_id           VARCHAR(80),
  adjustment_date            DATE,
  currency_code              CHAR(3),
  adjustment_amount          DECIMAL(18,2),
  dq_status                  VARCHAR(10)    NOT NULL DEFAULT 'PASS',
  batch_run_id               BIGINT         NOT NULL,
  transformed_ts             TIMESTAMP      NOT NULL DEFAULT CURRENT TIMESTAMP,
  CONSTRAINT PK_WRK_ADJ PRIMARY KEY (wrk_adjustment_event_id),
  CONSTRAINT UQ_WRK_ADJ_1 UNIQUE (source_system_id, source_adjustment_id)
);

CREATE TABLE WRK_INS.WRK_FX_RATE (
  wrk_fx_rate_id             BIGINT         NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
  source_system_id           VARCHAR(40)    NOT NULL,
  rate_date                  DATE           NOT NULL,
  from_currency_code         CHAR(3)        NOT NULL,
  to_currency_code           CHAR(3)        NOT NULL,
  fx_rate                    DECIMAL(18,8)  NOT NULL,
  dq_status                  VARCHAR(10)    NOT NULL DEFAULT 'PASS',
  batch_run_id               BIGINT         NOT NULL,
  transformed_ts             TIMESTAMP      NOT NULL DEFAULT CURRENT TIMESTAMP,
  CONSTRAINT PK_WRK_FX PRIMARY KEY (wrk_fx_rate_id),
  CONSTRAINT UQ_WRK_FX_1 UNIQUE (source_system_id, rate_date, from_currency_code, to_currency_code)
);

CREATE TABLE WRK_INS.WRK_REJECT (
  wrk_reject_id              BIGINT        NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
  layer_name                 VARCHAR(10)   NOT NULL,
  entity_name                VARCHAR(40)   NOT NULL,
  source_system_id           VARCHAR(40),
  source_business_key        VARCHAR(200),
  dq_rule_id                 VARCHAR(30)   NOT NULL,
  dq_message                 VARCHAR(500),
  batch_run_id               BIGINT        NOT NULL,
  rejected_ts                TIMESTAMP     NOT NULL DEFAULT CURRENT TIMESTAMP,
  CONSTRAINT PK_WRK_REJECT PRIMARY KEY (wrk_reject_id)
);
