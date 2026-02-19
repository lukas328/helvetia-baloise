# DDL Package (IBM DB2 LUW)

Last updated: 2026-02-08

This folder contains DDL exports for each architectural layer.

## Execution Order

1. `ddl/00_schemas.sql`
2. `ddl/10_stg_layer.sql`
3. `ddl/20_wrk_layer.sql`
4. `ddl/30_dwh_core_layer.sql`
5. `ddl/40_dm_sales_provisioning_layer.sql`
6. `ddl/50_ctl_layer.sql`

## Layer Intent

- `STG_INS`: Raw landing layer, schema-on-read and ingestion metadata.
- `WRK_INS`: Standardized and validated integration work layer.
- `DWH_CORE`: Generic, mart-independent enterprise DWH model.
- `DM_VERSICHERUNG`: Sales provisioning data mart model.
- `CTL_INS`: Operational control, run metadata, quality, and reconciliation.

## Notes

- Scripts are written for IBM DB2 LUW.
- `CREATE SCHEMA` statements are intentionally explicit; reruns may require cleanup or conditional wrappers based on deployment standards.
