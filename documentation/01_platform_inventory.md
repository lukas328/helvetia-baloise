# 01 Platform Inventory

## Repository Structure

Top-level folders:
- `ddl/`: DB2 DDL scripts for all architectural layers.
- `sas/`: SAS ETL implementation for core-to-mart load, run control, and quality.

Subfolders in `sas/`:
- `sas/config/`: runtime options, environment parameters, DB2 libname setup.
- `sas/ctl/`: batch run start/end logic and watermark update.
- `sas/macros/`: reusable ETL, logging, DQ, and reconciliation macros.
- `sas/mapping/`: 13 mapping steps to populate dimensions, bridges, and facts.
- `sas/quality/`: DQ assertions and reconciliation checks.

## Technology Stack

- Database platform: IBM DB2 LUW.
- ETL orchestration: SAS batch scripts and macros.
- Data model style:
  - Multi-layer enterprise warehouse (`STG`, `WRK`, `CORE`, `DM`, `CTL`).
  - Core + departmental mart pattern.
  - SCD-style historization for selected dimensions.

## DDL Package Content

Execution order (from `ddl/README.md`):
1. `ddl/00_schemas.sql`
2. `ddl/10_stg_layer.sql`
3. `ddl/20_wrk_layer.sql`
4. `ddl/30_dwh_core_layer.sql`
5. `ddl/40_dm_sales_provisioning_layer.sql`
6. `ddl/50_ctl_layer.sql`

Schemas:
- `STG_INS`: raw ingestion landing tables.
- `WRK_INS`: standardized/validated work layer.
- `DWH_CORE`: enterprise, mart-independent canonical model.
- `DM_VERSICHERUNG`: sales provisioning data mart.
- `CTL_INS`: control, quality, reconciliation, and alerting.

## Object Counts

Tables by schema:
- `STG_INS`: 14
- `WRK_INS`: 11
- `DWH_CORE`: 18
- `DM_VERSICHERUNG`: 15
- `CTL_INS`: 6

SAS assets:
- Mapping scripts: 13
- Quality scripts: 2
- Macros: 6
- Main orchestrator: 1 (`sas/run_dm_sales_provisioning.sas`)

## Main Operational Artifacts

Orchestrator:
- `sas/run_dm_sales_provisioning.sas`

Control scripts:
- `sas/ctl/01_start_run.sas`
- `sas/ctl/02_end_run.sas`

Reusable macros:
- `sas/macros/m_log_run.sas`
- `sas/macros/m_scd2_merge.sas`
- `sas/macros/m_fact_upsert.sas`
- `sas/macros/m_lookup_key.sas`
- `sas/macros/m_dq_assert.sas`
- `sas/macros/m_recon_metric.sas`

## Functional Scope Present vs Missing

Present in repository:
- Full schema definitions from staging to mart.
- Full ETL logic for `DWH_CORE -> DM_VERSICHERUNG`.
- DQ and reconciliation checks for mart facts.
- Run-level and step-level control/audit inserts.

Missing from repository:
- ETL code from `STG_INS -> WRK_INS`.
- ETL code from `WRK_INS -> DWH_CORE`.
- Any loader or CDC ingest scripts from operational source systems into `STG_INS`.

Implication:
- Full lineage is structurally inferable through DDL, but executable lineage logic is only directly visible from `DWH_CORE` to `DM_VERSICHERUNG`.
