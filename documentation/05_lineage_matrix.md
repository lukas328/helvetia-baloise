# 05 Lineage Matrix

## End-To-End Logical Lineage

Logical (DDL-defined) platform lineage:
- Source systems -> `STG_INS.*` -> `WRK_INS.*` -> `DWH_CORE.*` -> `DM_VERSICHERUNG.*`

Implemented (SAS-visible) lineage in this repository:
- `DWH_CORE.*` -> `DM_VERSICHERUNG.*` (+ `CTL_INS.*` for controls)

Fact lineage diagram:
- `documentation/diagrams/05_fact_lineage_flow.mmd`

## Dimension And Bridge Lineage (CORE -> DM)

| Target DM Object | Primary CORE Source(s) | Business/Join Logic | Load Mode |
|---|---|---|---|
| `DIM_DATUM` | `CORE_DATE` | `datum_key = date_key` | update + insert |
| `DIM_WAEHRUNG` | `CORE_CURRENCY` | `waehrung_key = currency_key` (`is_current='J'`) | update + insert |
| `DIM_ORGANISATIONSEINHEIT` | `CORE_ORG_UNIT` | `oe_code = org_unit_code` | update + insert |
| `DIM_VERTRIEBSKANAL` | `CORE_CHANNEL` | `kanal_code = channel_code` | update + insert |
| `DIM_GRUND` | `CORE_REASON` | `grund_code = reason_code` | update + insert |
| `DIM_POLICE` | `CORE_POLICY` | BK `policenummer = policy_number`, SCD by `valid_from` | SCD-style merge |
| `DIM_PRODUKT` | `CORE_PRODUCT` | BK `produkt_code = product_code`, SCD by `valid_from` | SCD-style merge |
| `DIM_VERMITTLER` | `CORE_PARTY_ROLE` + `CORE_PARTY` | BK `role_identifier` else `SRC-source_party_id`, SCD by intersected validity | SCD-style merge |
| `DIM_PROVISIONSPLAN` | `CORE_COMMISSION_PLAN` | BK `plan_code`, SCD by `valid_from` | SCD-style merge |
| `DIM_PROVISIONSREGEL` | `CORE_COMMISSION_RULE` | BK `regel_code`, SCD by `valid_from` | SCD-style merge |
| `BR_POLICE_VERMITTLER_AUFTEILUNG` | `CORE_POLICY_AGENT_ASSIGNMENT` + `CORE_POLICY` + DM dims | Policy-agent allocation by valid-from snapshot and normalized split % | full delete + reload |
| `BR_VERMITTLER_HIERARCHIE` | `CORE_POLICY_AGENT_ASSIGNMENT` + role/party | Agent-supervisor pairs, self-links removed | full delete + reload |

## Fact Lineage (CORE -> DM)

| Target Fact | CORE Transaction Source | Additional Source Objects | Natural Key Used In Upsert |
|---|---|---|---|
| `FKT_VERTRIEBSPROVISIONSEREIGNIS` | `CORE_PROVISION_TRANSACTION` | `CORE_PREMIUM_TRANSACTION`, `CORE_POLICY`, `CORE_PRODUCT`, role/party, channel, org, plan, rule, `CORE_FX_RATE`, DM dims | `quell_system_id`, `praemientransaktion_id`, `vermittler_key`, `abrechnungsperiode`, `abgrenzungsdatum_key` |
| `FKT_PROVISIONSAUSZAHLUNG` | `CORE_PAYOUT_TRANSACTION` | links via `CORE_PROVISION_TRANSACTION` + `CORE_PREMIUM_TRANSACTION`; role/party, org, `CORE_FX_RATE`, `FKT_VERTRIEBSPROVISIONSEREIGNIS` | `auszahlung_id`, `provisionsereignis_key` |
| `FKT_PROVISIONSANPASSUNG` | `CORE_ADJUSTMENT_TRANSACTION` | links via `CORE_PROVISION_TRANSACTION` + `CORE_PREMIUM_TRANSACTION`; role/party, reason, `CORE_FX_RATE`, `FKT_VERTRIEBSPROVISIONSEREIGNIS` | `anpassung_id` |

## Selected Field-Level Lineage

### `FKT_VERTRIEBSPROVISIONSEREIGNIS`

Key mappings:
- `police_key` <- `DIM_POLICE` via `CORE_POLICY.policy_number` and event-date validity.
- `produkt_key` <- `DIM_PRODUKT` via `CORE_PRODUCT.product_code` and event-date validity.
- `vermittler_key` <- `DIM_VERMITTLER` via role identifier (or fallback synthetic ID) and event-date validity.
- `provisionsplan_key` <- `DIM_PROVISIONSPLAN` via plan code and event-date validity.
- `provisionsregel_key` <- `DIM_PROVISIONSREGEL` via rule code and event-date validity.

Measure mappings:
- `bruttopraemie_betrag` <- `CORE_PREMIUM_TRANSACTION.gross_amount`
- `provisionsbasis_betrag` <- `CORE_PROVISION_TRANSACTION.provision_base_amount` fallback premium net/gross
- `provisionssatz` <- `CORE_PROVISION_TRANSACTION.provision_rate`
- `brutto_provision_betrag` <- core gross provision fallback `basis * satz`
- `stornohaftung_betrag` <- `CORE_PROVISION_TRANSACTION.clawback_amount`
- `steuer_betrag` <- `CORE_PROVISION_TRANSACTION.tax_amount`
- `netto_provision_betrag` <- core net provision fallback derived arithmetic
- `fx_kurs` <- exact/fallback `CORE_FX_RATE` (to reporting ccy)
- `netto_provision_report_ccy` <- `round(netto_provision_betrag * fx_kurs, 0.01)`

Rejection conditions:
- Missing FX for non-reporting currency.

### `FKT_PROVISIONSAUSZAHLUNG`

Key mappings:
- `provisionsereignis_key` <- match to central fact using source system, premium txn id, agent key, accrual date, and accrual period.
- `vermittler_key` <- resolved via role/party to `DIM_VERMITTLER`.

Measure mappings:
- `ausgezahlt_betrag` <- `CORE_PAYOUT_TRANSACTION.payout_amount`
- `quellensteuer_betrag` <- `withholding_tax_amount`
- `zahlungsgebuehr_betrag` <- `payment_fee_amount`
- `ausgezahlt_report_ccy` <- `round(ausgezahlt_betrag * fx_kurs, 0.01)`

Rejection conditions:
- Missing linked `provisionsereignis_key`.
- Missing FX for non-reporting currency.

### `FKT_PROVISIONSANPASSUNG`

Key mappings:
- `provisionsereignis_key` <- same linking strategy as payout.
- `grund_key` <- `DIM_GRUND` via `CORE_REASON.reason_code`.

Measure mappings:
- `anpassung_betrag` <- `CORE_ADJUSTMENT_TRANSACTION.adjustment_amount`
- `anpassung_report_ccy` <- `round(anpassung_betrag * fx_kurs, 0.01)`

Rejection conditions:
- Missing linked `provisionsereignis_key`.
- Missing FX for non-reporting currency.

## Lineage Observability Hooks

Available control evidence:
- Step-level row counters in `CTL_BATCH_STEP`.
- DQ outcomes in `CTL_DQ_RESULT`.
- Reconciliation values in `CTL_RECON_RESULT`.

Not implemented in visible code:
- Population of `DWH_CORE.CORE_RECORD_LINEAGE` from SAS mappings.
