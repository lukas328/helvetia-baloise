-- ============================================================
-- Helvetia Insurance DWH + Data Mart
-- Layer: CTL_INS (control, quality, reconciliation)
-- ============================================================

CREATE TABLE CTL_INS.CTL_BATCH_RUN (
  batch_run_id              BIGINT        NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
  pipeline_name             VARCHAR(80)   NOT NULL,
  trigger_type              VARCHAR(20)   NOT NULL,
  source_cutoff_ts          TIMESTAMP,
  run_start_ts              TIMESTAMP     NOT NULL DEFAULT CURRENT TIMESTAMP,
  run_end_ts                TIMESTAMP,
  run_status                VARCHAR(20)   NOT NULL DEFAULT 'RUNNING',
  initiated_by              VARCHAR(80),
  CONSTRAINT PK_CTL_BATCH_RUN PRIMARY KEY (batch_run_id),
  CONSTRAINT CK_CTL_BATCH_RUN_1 CHECK (run_status IN ('RUNNING','SUCCEEDED','FAILED','CANCELLED'))
);

CREATE TABLE CTL_INS.CTL_BATCH_STEP (
  batch_step_id             BIGINT        NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
  batch_run_id              BIGINT        NOT NULL,
  step_name                 VARCHAR(80)   NOT NULL,
  step_order                SMALLINT      NOT NULL,
  step_start_ts             TIMESTAMP     NOT NULL DEFAULT CURRENT TIMESTAMP,
  step_end_ts               TIMESTAMP,
  step_status               VARCHAR(20)   NOT NULL DEFAULT 'RUNNING',
  rows_read                 BIGINT        NOT NULL DEFAULT 0,
  rows_written              BIGINT        NOT NULL DEFAULT 0,
  rows_rejected             BIGINT        NOT NULL DEFAULT 0,
  error_message             VARCHAR(1000),
  CONSTRAINT PK_CTL_BATCH_STEP PRIMARY KEY (batch_step_id),
  CONSTRAINT FK_CTL_BATCH_STEP_1 FOREIGN KEY (batch_run_id) REFERENCES CTL_INS.CTL_BATCH_RUN(batch_run_id),
  CONSTRAINT CK_CTL_BATCH_STEP_1 CHECK (step_status IN ('RUNNING','SUCCEEDED','FAILED','SKIPPED'))
);

CREATE TABLE CTL_INS.CTL_WATERMARK (
  watermark_id              BIGINT        NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
  pipeline_name             VARCHAR(80)   NOT NULL,
  source_system_id          VARCHAR(40)   NOT NULL,
  entity_name               VARCHAR(80)   NOT NULL,
  last_success_ts           TIMESTAMP     NOT NULL,
  updated_ts                TIMESTAMP     NOT NULL DEFAULT CURRENT TIMESTAMP,
  CONSTRAINT PK_CTL_WATERMARK PRIMARY KEY (watermark_id),
  CONSTRAINT UQ_CTL_WATERMARK_1 UNIQUE (pipeline_name, source_system_id, entity_name)
);

CREATE TABLE CTL_INS.CTL_DQ_RESULT (
  dq_result_id              BIGINT        NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
  batch_run_id              BIGINT        NOT NULL,
  layer_name                VARCHAR(20)   NOT NULL,
  entity_name               VARCHAR(80)   NOT NULL,
  dq_rule_id                VARCHAR(30)   NOT NULL,
  severity                  VARCHAR(10)   NOT NULL,
  tested_rows               BIGINT        NOT NULL DEFAULT 0,
  failed_rows               BIGINT        NOT NULL DEFAULT 0,
  pass_flag                 CHAR(1)       NOT NULL,
  measured_ts               TIMESTAMP     NOT NULL DEFAULT CURRENT TIMESTAMP,
  CONSTRAINT PK_CTL_DQ_RESULT PRIMARY KEY (dq_result_id),
  CONSTRAINT FK_CTL_DQ_RESULT_1 FOREIGN KEY (batch_run_id) REFERENCES CTL_INS.CTL_BATCH_RUN(batch_run_id),
  CONSTRAINT CK_CTL_DQ_RESULT_1 CHECK (severity IN ('INFO','WARN','ERROR')),
  CONSTRAINT CK_CTL_DQ_RESULT_2 CHECK (pass_flag IN ('J','N'))
);

CREATE TABLE CTL_INS.CTL_RECON_RESULT (
  recon_result_id           BIGINT         NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
  batch_run_id              BIGINT         NOT NULL,
  recon_scope               VARCHAR(40)    NOT NULL,
  recon_metric              VARCHAR(80)    NOT NULL,
  recon_grain               VARCHAR(120),
  source_value              DECIMAL(20,4)  NOT NULL,
  target_value              DECIMAL(20,4)  NOT NULL,
  variance_value            DECIMAL(20,4)  NOT NULL,
  tolerance_value           DECIMAL(20,4)  NOT NULL,
  pass_flag                 CHAR(1)        NOT NULL,
  measured_ts               TIMESTAMP      NOT NULL DEFAULT CURRENT TIMESTAMP,
  CONSTRAINT PK_CTL_RECON_RESULT PRIMARY KEY (recon_result_id),
  CONSTRAINT FK_CTL_RECON_RESULT_1 FOREIGN KEY (batch_run_id) REFERENCES CTL_INS.CTL_BATCH_RUN(batch_run_id),
  CONSTRAINT CK_CTL_RECON_RESULT_1 CHECK (pass_flag IN ('J','N'))
);

CREATE TABLE CTL_INS.CTL_ALERT (
  alert_id                  BIGINT        NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
  batch_run_id              BIGINT,
  alert_type                VARCHAR(40)   NOT NULL,
  severity                  VARCHAR(10)   NOT NULL,
  alert_message             VARCHAR(1000) NOT NULL,
  created_ts                TIMESTAMP     NOT NULL DEFAULT CURRENT TIMESTAMP,
  acknowledged_flag         CHAR(1)       NOT NULL DEFAULT 'N',
  acknowledged_by           VARCHAR(80),
  acknowledged_ts           TIMESTAMP,
  CONSTRAINT PK_CTL_ALERT PRIMARY KEY (alert_id),
  CONSTRAINT FK_CTL_ALERT_1 FOREIGN KEY (batch_run_id) REFERENCES CTL_INS.CTL_BATCH_RUN(batch_run_id),
  CONSTRAINT CK_CTL_ALERT_1 CHECK (severity IN ('INFO','WARN','ERROR','CRITICAL')),
  CONSTRAINT CK_CTL_ALERT_2 CHECK (acknowledged_flag IN ('J','N'))
);

CREATE INDEX CTL_INS.IX_CTL_BATCH_STEP_1 ON CTL_INS.CTL_BATCH_STEP (batch_run_id, step_order);
CREATE INDEX CTL_INS.IX_CTL_DQ_RESULT_1 ON CTL_INS.CTL_DQ_RESULT (batch_run_id, layer_name, entity_name);
CREATE INDEX CTL_INS.IX_CTL_RECON_RESULT_1 ON CTL_INS.CTL_RECON_RESULT (batch_run_id, recon_scope);
