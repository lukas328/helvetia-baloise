# 02 Architecture And Data Flow

## Architectural Pattern

The platform is designed as a layered insurance DWH with a downstream provisioning data mart.

Logical flow:
1. Source systems load raw records into `STG_INS`.
2. `WRK_INS` standardizes, validates, and flags data quality status.
3. `DWH_CORE` stores canonical business entities and transactions.
4. `DM_VERSICHERUNG` reshapes data for sales provisioning analytics.
5. `CTL_INS` stores operational telemetry, quality, and reconciliation outcomes.

Diagram:
- `documentation/diagrams/01_architecture_layers.mmd`

## Layer Responsibilities

### STG_INS (Raw Landing)
- Stores source keys and payload with ingestion metadata (`batch_run_id`, `source_extract_ts`, `source_file_name`, `row_hash`, `ingested_ts`).
- Raw structures are close to source shape (policy, party, product, transactions, FX rates).
- Minimal business constraints beyond primary keys and basic checks.

### WRK_INS (Integration Work)
- Normalizes source records and adds quality flagging (`dq_status`).
- Adds uniqueness constraints at source/business key grain.
- Provides rejection table (`WRK_REJECT`) for failed rule outcomes.

### DWH_CORE (Canonical Enterprise Model)
- Represents enterprise entities independent of specific marts.
- Contains:
  - Conformed dimensions (`CORE_DATE`, `CORE_CURRENCY`, `CORE_ORG_UNIT`, `CORE_CHANNEL`, `CORE_REASON`).
  - Master entities with historization (`CORE_PARTY`, `CORE_PRODUCT`, `CORE_POLICY`, plans/rules).
  - Relationship entities (`CORE_PARTY_ROLE`, `CORE_POLICY_AGENT_ASSIGNMENT`).
  - Atomic finance transactions (premium/provision/payout/adjustment).
  - FX rates and lineage table.

### DM_VERSICHERUNG (Sales Provisioning Mart)
- German business naming and reporting-friendly model.
- Contains dimensions, 2 bridge tables, and 3 facts:
  - `FKT_VERTRIEBSPROVISIONSEREIGNIS` (accrual fact)
  - `FKT_PROVISIONSAUSZAHLUNG` (payout fact)
  - `FKT_PROVISIONSANPASSUNG` (adjustment fact)

### CTL_INS (Operational Control)
- Tracks pipeline run and step status.
- Persists DQ and reconciliation results.
- Holds per-entity watermarks updated on successful runs.

## Orchestration Flow (Implemented)

Primary batch script: `sas/run_dm_sales_provisioning.sas`

Execution order:
1. Load options and runtime parameters.
2. Assign DB2 libnames.
3. Load macros.
4. Start run (`CTL_BATCH_RUN`, then step log).
5. Execute 13 mapping scripts in deterministic order.
6. Execute DQ assertions.
7. Execute reconciliation checks.
8. End run: finalize status, update watermarks when successful.

Sequence diagram:
- `documentation/diagrams/02_orchestration_sequence.mmd`

## Incremental Window Strategy

Configured runtime values (`sas/config/20_runtime_parameters.sas`):
- Reporting currency: `CHF`
- Reprocessing window: `45` days
- Lower bound key: `g_min_event_date` (YYYYMMDD integer from today minus 45 days)

Applied to facts and quality checks:
- Accrual based on `event_effective_date_key`.
- Payout based on `payout_date_key`.
- Adjustment based on `adjustment_date_key`.

## Currency Conversion Strategy

In fact mappings, conversion to reporting currency follows:
1. Exact FX rate for transaction date.
2. Fallback FX: latest prior rate within last 5 calendar days.
3. If source currency equals reporting currency, rate defaults to `1`.
4. Otherwise rows with missing FX rate are rejected from mart load.

## Unknown/Default Dimension Strategy

The DM load enforces unknown/default members and fallback keys.
Examples:
- Date unknown: `19000101` (`01JAN1900`).
- Currency unknown: `'UNK'`.
- Various dimensions use `'UNK'` or `'UNKNOWN'` business keys.

Purpose:
- Preserve referential completeness where possible.
- Avoid hard failures for missing dimension references.

Tradeoff:
- Can hide upstream mastering issues unless monitored via DQ/recon trends.
