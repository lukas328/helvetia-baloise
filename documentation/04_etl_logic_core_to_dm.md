# 04 ETL Logic Core To DM

This section documents executable transformation logic in `sas/mapping/*.sas`.

## Run Order

The orchestrator executes mappings in this strict order:
1. `01_dim_datum.sas`
2. `02_dim_waehrung.sas`
3. `03_dim_organisation_kanal_grund.sas`
4. `04_dim_police.sas`
5. `05_dim_produkt.sas`
6. `06_dim_vermittler.sas`
7. `07_dim_provisionsplan.sas`
8. `08_dim_provisionsregel.sas`
9. `09_bridge_police_vermittler.sas`
10. `10_bridge_vermittler_hierarchie.sas`
11. `11_fact_vertriebsprovisionsereignis.sas`
12. `12_fact_provisionsauszahlung.sas`
13. `13_fact_provisionsanpassung.sas`

## Common ETL Patterns

### Pattern A: Unknown Member Seeding
Most dimensions seed unknown records when absent.
Examples:
- `DIM_DATUM`: key `19000101`
- `DIM_WAEHRUNG`: key `UNK`
- Other dimensions: business keys `UNK` or `UNKNOWN`

### Pattern B: SCD-Like Merge For Dimensions
Used for:
- `DIM_POLICE`
- `DIM_PRODUKT`
- `DIM_VERMITTLER`
- `DIM_PROVISIONSPLAN`
- `DIM_PROVISIONSREGEL`

Implemented via `%m_scd2_merge`:
- Inserts missing `(business_key, valid_from)` rows.
- Updates selected descriptive/hash columns when same `(business_key, valid_from)` exists.
- Does not independently close/open validity windows.

### Pattern C: Fact Insert-Only Upsert
Used for all 3 fact tables via `%m_fact_upsert`:
- Builds `work._fact_to_insert` by anti-join on configured natural key.
- Appends only new rows.
- Does not update existing facts if non-key attributes change.

### Pattern D: Date-Effective Dimension Resolution
Fact mappings resolve SCD keys by joining event date between `gueltig_von` and `gueltig_bis`.

### Pattern E: FX Conversion + Rejection
Facts requiring reporting currency conversion:
- derive `fx_kurs` (exact, fallback <= 5 days, or 1 for reporting currency).
- reject non-reporting-currency rows with missing FX.

## Mapping Details

### 01 DIM_DATUM
Source: `DWHCORE.CORE_DATE`
Logic:
- Ensure unknown date row.
- Update existing dates from core.
- Insert new dates by `date_key`.

### 02 DIM_WAEHRUNG
Source: `DWHCORE.CORE_CURRENCY` where `is_current='J'`
Logic:
- Ensure `UNK` row.
- Update existing currencies.
- Insert missing currencies.

### 03 DIM_ORGANISATIONSEINHEIT, DIM_VERTRIEBSKANAL, DIM_GRUND
Sources:
- `CORE_ORG_UNIT`
- `CORE_CHANNEL`
- `CORE_REASON`
Logic:
- Ensure unknown rows for all three dimensions.
- Update existing by business codes.
- Insert missing business codes.

### 04 DIM_POLICE
Source: `CORE_POLICY`
Business key: `policenummer`
Validity: `gueltig_von = valid_from`, `gueltig_bis = valid_to`
Logic:
- Build source projection.
- Merge via `%m_scd2_merge`.

### 05 DIM_PRODUKT
Source: `CORE_PRODUCT`
Business key: `produkt_code`
Logic:
- Build source projection with defaults.
- Merge via `%m_scd2_merge`.

### 06 DIM_VERMITTLER
Sources:
- `CORE_PARTY_ROLE`
- `CORE_PARTY`
Agent role filter:
- `AGENT`, `BROKER`, `VERMITTLER`
Business key derivation:
- `role_identifier` else `SRC-{source_party_id}`
Validity:
- intersection of party and role validity intervals.

### 07 DIM_PROVISIONSPLAN
Source: `CORE_COMMISSION_PLAN`
Business key: `plan_code`
Logic:
- Build source projection.
- Merge via `%m_scd2_merge`.

### 08 DIM_PROVISIONSREGEL
Source: `CORE_COMMISSION_RULE`
Business key: `regel_code`
Logic:
- Build compact description from `base_type_code` and `source_rule_id`.
- Merge via `%m_scd2_merge`.

### 09 BR_POLICE_VERMITTLER_AUFTEILUNG
Source: `CORE_POLICY_AGENT_ASSIGNMENT`
Logic:
- Resolve DM police and agent keys with date-valid joins.
- Compute per-policy split sum per `valid_from`.
- Keep only near-100% groups (`99.5 .. 100.5`) and positive split.
- Normalize split to exactly 100% style ratio.
- Full refresh strategy: delete target then append.

### 10 BR_VERMITTLER_HIERARCHIE
Source: `CORE_POLICY_AGENT_ASSIGNMENT` + party-role links
Logic:
- Resolve subordinate and supervisor agent keys.
- Set hierarchy level `ebene = 1`.
- Remove self-relations.
- Full refresh strategy: delete target then append.

### 11 FKT_VERTRIEBSPROVISIONSEREIGNIS
Primary source: `CORE_PROVISION_TRANSACTION`
Joined with:
- `CORE_PREMIUM_TRANSACTION`, `CORE_POLICY`, `CORE_PRODUCT`
- party/role, channel, org, plan, rule
- DM dimensions for surrogate keys
- `CORE_FX_RATE` for conversion
Filters:
- only rows with `event_effective_date_key >= g_min_event_date`
Natural key used in `%m_fact_upsert`:
- `quell_system_id`
- `praemientransaktion_id`
- `vermittler_key`
- `abrechnungsperiode`
- `abgrenzungsdatum_key`
Derived measures include:
- `provisionsbasis_betrag`, `brutto_provision_betrag`, `netto_provision_betrag`, `netto_provision_report_ccy`

### 12 FKT_PROVISIONSAUSZAHLUNG
Primary source: `CORE_PAYOUT_TRANSACTION`
Linked to central fact by matching to loaded accrual fact key attributes.
Filters:
- `payout_date_key >= g_min_event_date`
- drop rows with missing linked `provisionsereignis_key`
- drop rows with missing FX for non-reporting currency
Natural key:
- `auszahlung_id`, `provisionsereignis_key`

### 13 FKT_PROVISIONSANPASSUNG
Primary source: `CORE_ADJUSTMENT_TRANSACTION`
Linked to central fact similarly to payout mapping.
Filters:
- `adjustment_date_key >= g_min_event_date`
- drop rows with missing linked `provisionsereignis_key`
- drop rows with missing FX for non-reporting currency
Natural key:
- `anpassung_id`

## Reusable Macro Semantics

### `%m_log_run`
- Inserts one row into `CTL_BATCH_STEP` per logical step.
- Increments global `g_step_order`.

### `%m_scd2_merge`
- Anti-join insert for missing BK + valid_from.
- Optional in-place update for declared hash columns.

### `%m_fact_upsert`
- Anti-join insert for missing natural keys.
- Exposes `g_last_rows_read` and `g_last_rows_written` for logging.

### `%m_lookup_key`
- Generic valid-time lookup macro.
- Not used by current mapping scripts.
