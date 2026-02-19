# 03 Entity Model Reference

## Model Conventions

Key types:
- Source key: `source_*` columns (business keys from source systems).
- Surrogate key: generated numeric keys (identity columns).
- Date key: integer `YYYYMMDD` style (`date_key`, `*_date_key`).

Historization patterns:
- Core and DM dimensions commonly use `valid_from`/`valid_to` and current flag (`is_current` or `ist_aktuell`).
- Facts are event transactions keyed by source identifiers and joined to dimensions.

## DWH_CORE Entity Catalog

### Conformed Dimensions

1. `DWH_CORE.CORE_DATE`
- Grain: one row per calendar date.
- PK: `date_key`.
- Alternate key: `calendar_date`.

2. `DWH_CORE.CORE_CURRENCY`
- Grain: currency code (with validity interval fields).
- PK: `currency_key` (3-char ISO-like code).

3. `DWH_CORE.CORE_ORG_UNIT`
- Grain: source org unit per validity interval.
- PK: `org_unit_key`.
- UK: `(source_system_id, source_org_unit_id, valid_from)`.

4. `DWH_CORE.CORE_CHANNEL`
- Grain: source channel per validity interval.
- PK: `channel_key`.

5. `DWH_CORE.CORE_REASON`
- Grain: source reason per validity interval.
- PK: `reason_key`.

### Master Entities

6. `DWH_CORE.CORE_PARTY`
- Grain: source party per validity interval.
- PK: `party_key`.

7. `DWH_CORE.CORE_PARTY_ROLE`
- Grain: party role assignment per validity interval.
- PK: `party_role_key`.
- FK: `party_key -> CORE_PARTY`.

8. `DWH_CORE.CORE_PRODUCT`
- Grain: source product per validity interval.
- PK: `product_key`.

9. `DWH_CORE.CORE_POLICY`
- Grain: source policy per validity interval.
- PK: `policy_key`.
- FK: policyholder party and product.

10. `DWH_CORE.CORE_POLICY_AGENT_ASSIGNMENT`
- Grain: policy-agent assignment per validity interval.
- PK: `policy_agent_assignment_key`.
- FK: policy, agent role, supervisor role, org unit, channel.

11. `DWH_CORE.CORE_COMMISSION_PLAN`
- Grain: plan per validity interval.
- PK: `commission_plan_key`.

12. `DWH_CORE.CORE_COMMISSION_RULE`
- Grain: rule per validity interval.
- PK: `commission_rule_key`.
- FK: `commission_plan_key`.

### Transactional Entities

13. `DWH_CORE.CORE_FX_RATE`
- Grain: source + date + currency pair.
- PK: `fx_rate_key`.

14. `DWH_CORE.CORE_PREMIUM_TRANSACTION`
- Grain: one premium transaction event.
- PK: `premium_txn_key`.
- UK: `(source_system_id, source_premium_txn_id)`.

15. `DWH_CORE.CORE_PROVISION_TRANSACTION`
- Grain: one provision/accrual event.
- PK: `provision_txn_key`.
- UK: `(source_system_id, source_provision_event_id)`.

16. `DWH_CORE.CORE_PAYOUT_TRANSACTION`
- Grain: one payout event.
- PK: `payout_txn_key`.
- UK: `(source_system_id, source_payout_id)`.

17. `DWH_CORE.CORE_ADJUSTMENT_TRANSACTION`
- Grain: one adjustment event.
- PK: `adjustment_txn_key`.
- UK: `(source_system_id, source_adjustment_id)`.

18. `DWH_CORE.CORE_RECORD_LINEAGE`
- Purpose: record-level lineage/audit registry.
- Note: defined in DDL; no population logic is present in available SAS scripts.

Core ER diagram:
- `documentation/diagrams/03_core_er_model.mmd`

## DM_VERSICHERUNG Entity Catalog

### Dimensions

1. `DIM_DATUM`
- Conformed date dimension in German naming.

2. `DIM_WAEHRUNG`
- Currency dimension with `reporting_flag`.

3. `DIM_ORGANISATIONSEINHEIT`
- Org unit dimension, natural key `oe_code`.

4. `DIM_VERTRIEBSKANAL`
- Channel dimension, natural key `kanal_code`.

5. `DIM_GRUND`
- Reason dimension, natural key `grund_code`.

6. `DIM_POLICE`
- Policy SCD-like dimension, natural key `policenummer + gueltig_von`.

7. `DIM_PRODUKT`
- Product SCD-like dimension.

8. `DIM_VERMITTLER`
- Agent/broker dimension with validity windows.

9. `DIM_PROVISIONSPLAN`
- Commission plan SCD-like dimension.

10. `DIM_PROVISIONSREGEL`
- Commission rule SCD-like dimension.

### Facts

11. `FKT_VERTRIEBSPROVISIONSEREIGNIS`
- Grain: one accrual event at policy/premium transaction/agent/accrual-period level.
- Central fact for downstream payout and adjustment linking.

12. `FKT_PROVISIONSAUSZAHLUNG`
- Grain: payout event linked to central accrual event.

13. `FKT_PROVISIONSANPASSUNG`
- Grain: adjustment event linked to central accrual event.

### Bridges

14. `BR_POLICE_VERMITTLER_AUFTEILUNG`
- Bridge for policy-agent split percentages over validity windows.

15. `BR_VERMITTLER_HIERARCHIE`
- Bridge for subordinate-supervisor agent hierarchy.

DM star/bridge diagram:
- `documentation/diagrams/04_dm_star_and_bridges.mmd`

## CTL_INS Control Model

1. `CTL_BATCH_RUN`: run header
2. `CTL_BATCH_STEP`: step-level telemetry
3. `CTL_WATERMARK`: incremental anchors
4. `CTL_DQ_RESULT`: DQ outcomes
5. `CTL_RECON_RESULT`: reconciliation outcomes
6. `CTL_ALERT`: alerts (defined; not written by current SAS flow)
