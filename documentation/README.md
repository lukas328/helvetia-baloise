# Legacy DWH Platform Documentation

This folder documents the legacy IBM DB2 + SAS data warehouse platform found in this repository.

Scope analyzed:
- SQL DDL in `ddl/` (STG, WRK, CORE, DM, CTL layers)
- SAS orchestration, mappings, macros, and quality controls in `sas/`

## What Is Documented

1. `documentation/01_platform_inventory.md`
- Repository inventory, technology stack, and object counts.

2. `documentation/02_architecture_and_data_flow.md`
- Layer architecture and end-to-end processing flow.

3. `documentation/03_entity_model_reference.md`
- Core entities, table grains, SCD behavior, and relationship semantics.

4. `documentation/04_etl_logic_core_to_dm.md`
- Detailed SAS mapping logic from `DWH_CORE` to `DM_VERSICHERUNG`.

5. `documentation/05_lineage_matrix.md`
- Table-level and selected field-level lineage for dimensions, bridges, and facts.

6. `documentation/06_data_quality_reconciliation_and_controls.md`
- Batch control model, DQ assertions, reconciliation metrics, and watermark behavior.

7. `documentation/07_risks_and_recommendations.md`
- Risks found in current implementation and prioritized modernization backlog.

## Diagram Set

Diagram sources are under `documentation/diagrams/`:
- `documentation/diagrams/01_architecture_layers.mmd`
- `documentation/diagrams/02_orchestration_sequence.mmd`
- `documentation/diagrams/03_core_er_model.mmd`
- `documentation/diagrams/04_dm_star_and_bridges.mmd`
- `documentation/diagrams/05_fact_lineage_flow.mmd`
- `documentation/diagrams/06_control_quality_flow.mmd`

## Quick Facts

- Schemas: `STG_INS`, `WRK_INS`, `DWH_CORE`, `DM_VERSICHERUNG`, `CTL_INS`
- Tables by layer:
  - STG: 14
  - WRK: 11
  - CORE: 18
  - DM: 15
  - CTL: 6
- SAS mapping files: 13
- SAS quality files: 2
- SAS macro files: 6

## Important Boundary

This repository contains full DDL for all layers, but implemented SAS mappings only for `DWH_CORE -> DM_VERSICHERUNG`.
The ETL code for `STG_INS -> WRK_INS -> DWH_CORE` is not present here.
