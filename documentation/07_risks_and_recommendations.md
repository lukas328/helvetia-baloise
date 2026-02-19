# 07 Risks And Recommendations

This section captures design/operational risks identified from current code and DDL.

## High Priority Risks

1. Missing executable lineage for upstream layers
- Evidence: repository has DDL for `STG_INS` and `WRK_INS`, but no ETL scripts loading `WRK_INS` or `DWH_CORE` from those layers.
- Risk: incomplete operational understanding and weak auditability for full source-to-mart path.
- Recommendation: add upstream ETL code documentation or repository references; capture source ingestion contracts explicitly.

2. Orchestrator path hard-coded to different workspace
- Evidence: `sas/run_dm_sales_provisioning.sas` sets `g_sas_home=/home/dirk/workspace/helvetia/sas`.
- Risk: run failure or drift when code is executed from this repository path.
- Recommendation: externalize `g_sas_home` via environment parameter, CLI parameter, or relative path strategy.

3. Fact loads are insert-only
- Evidence: `%m_fact_upsert` inserts only anti-join rows and does not update existing matches.
- Risk: corrected source transactions with same natural key do not propagate to DM facts.
- Recommendation: implement merge/update strategy for mutable measures or enforce immutable source-event contract.

## Medium Priority Risks

4. SCD merge helper is not full SCD2 engine
- Evidence: `%m_scd2_merge` inserts missing BK+valid_from and updates columns for exact match; it does not auto-close prior records.
- Risk: if upstream validity windows overlap or shift, DM historization may become inconsistent.
- Recommendation: extend macro with interval management and overlap checks.

5. Bridge tables are full-refreshed each run
- Evidence: mapping 09 and 10 execute `delete from` target then `append`.
- Risk: larger runtime windows, lock contention, and reload volatility at scale.
- Recommendation: move to incremental merge keyed by business grain and validity start.

6. Record lineage table not populated
- Evidence: `DWH_CORE.CORE_RECORD_LINEAGE` exists in DDL but no SAS logic writes to it.
- Risk: weak traceability for record-level source-to-target auditing.
- Recommendation: add lineage writes for fact and dimension loads, at least for high-value entities.

7. Unknown-key fallback can hide data issues
- Evidence: frequent `UNK`/`UNKNOWN` dimension defaults and fallback surrogate keys.
- Risk: masked referential mapping defects become business-as-usual.
- Recommendation: monitor unknown-key rates per load and enforce alert thresholds.

## Low Priority / Hygiene Items

8. Unused macro indicates dead code
- Evidence: `%m_lookup_key` is included but unused by mappings.
- Risk: maintenance overhead and ambiguity.
- Recommendation: either use consistently for key resolution or remove it.

9. Step duration observability is weak
- Evidence: `step_start_ts` and `step_end_ts` written simultaneously in `m_log_run`.
- Risk: no reliable duration/performance trend at step level.
- Recommendation: write explicit step start and step end events or track elapsed time via macro wrappers.

10. Alert table not wired
- Evidence: `CTL_ALERT` defined but not written in shown flow.
- Risk: no centralized operational alert stream from DQ/recon failures.
- Recommendation: insert alerts on blocking DQ/recon failures and run failures.

## Suggested Delivery Backlog

1. Stabilize runtime configuration (`g_sas_home`, environment-driven parameters).
2. Add full-source lineage documentation and upstream ETL repository linkage.
3. Upgrade fact load strategy (merge updates for corrected events).
4. Implement proper SCD2 interval governance.
5. Add automated unknown-rate KPIs and alerting.
6. Activate `CTL_ALERT` and improve step duration metrics.
