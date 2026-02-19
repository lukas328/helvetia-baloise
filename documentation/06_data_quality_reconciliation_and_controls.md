# 06 Data Quality Reconciliation And Controls

## Run Control Lifecycle

Start of run (`sas/ctl/01_start_run.sas`):
1. Reset globals (`g_step_order`, `g_has_error`, `g_run_status`).
2. Insert `RUNNING` row into `CTL_BATCH_RUN`.
3. Resolve `g_batch_run_id`.
4. Write `RUN_START` step log.

End of run (`sas/ctl/02_end_run.sas`):
1. Set final run status (`FAILED` if `g_has_error > 0`, else `SUCCEEDED`).
2. Update `CTL_BATCH_RUN.run_end_ts` and `run_status`.
3. On success, upsert watermarks for:
   - `CORE_PROVISION_TRANSACTION`
   - `CORE_PAYOUT_TRANSACTION`
   - `CORE_ADJUSTMENT_TRANSACTION`
4. Write `RUN_END` step log.
5. Abort batch when status is failed.

Control flow diagram:
- `documentation/diagrams/06_control_quality_flow.mmd`

## Step Logging (`m_log_run`)

Writes one record to `CTL_BATCH_STEP` with:
- `batch_run_id`, step name/order
- status
- rows read/written/rejected
- optional error message

Operational note:
- `step_start_ts` and `step_end_ts` are both set to `datetime()` at insert time, so true step duration is not preserved.

## Data Quality Assertions (`quality/01_dq_core_to_dm.sas`)

Blocking severity (`ERROR`) checks:
1. `DQ_VPE_COMPLETENESS`
- Asserts no null foreign-key-like fields in accrual fact within reprocessing window.

2. `DQ_PAYOUT_FK`
- Asserts payout fact rows have non-null `provisionsereignis_key`.

3. `DQ_ADJUSTMENT_FK`
- Asserts adjustment fact rows have non-null `provisionsereignis_key`.

4. `DQ_BR_SPLIT_100`
- Asserts policy-agent bridge split sum per `(police_key, gueltig_von)` is approximately 100.

5. `DQ_VPE_DUP_GRAIN`
- Asserts no duplicates on accrual natural grain.

Storage:
- Every assertion writes to `CTL_DQ_RESULT` with tested rows, failed rows, pass flag, and severity.
- Failing `ERROR` assertions set `g_has_error=1`.

## Reconciliation Metrics (`quality/02_reconciliation_core_vs_dm.sas`)

All are blocking (`fail_severity=ERROR`) with tolerance `1.00`:
1. `RECON_ACCRUAL_NET_LOCAL`
- Compare sum of core net provision amount vs DM accrual net provision amount.

2. `RECON_PAYOUT_LOCAL`
- Compare sum of core payout amount vs DM payout amount.

3. `RECON_ADJUSTMENT_LOCAL`
- Compare sum of core adjustment amount vs DM adjustment amount.

Window:
- All source and target sums use the same rolling `g_min_event_date` boundary.

Storage:
- Results are stored in `CTL_RECON_RESULT` with source, target, variance, tolerance, and pass flag.

## Watermark Behavior

On successful run end, watermark rows are updated or inserted in `CTL_WATERMARK` by:
- `pipeline_name`
- `source_system_id`
- `entity_name`

Current strategy stores execution success timestamp, not source max business timestamp.
This is useful for orchestration but weaker for precise event-time replay/audit.

## Alert Model

`CTL_ALERT` table exists (DDL) with severity and acknowledgment fields.
No current SAS script inserts into `CTL_ALERT`, so alerting is schema-ready but not implemented in visible flow.
