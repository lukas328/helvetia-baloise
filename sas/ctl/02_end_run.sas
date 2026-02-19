%put NOTE: [CTL] End batch run for sales provisioning data mart load.;

%macro _upsert_watermark(entity_name=);
  proc sql noprint;
    update CTLINS.CTL_WATERMARK
    set
      last_success_ts = datetime(),
      updated_ts = datetime()
    where pipeline_name = "&g_pipeline_name"
      and source_system_id = "&g_source_system_default"
      and entity_name = "&entity_name";
  quit;

  %if &sqlobs = 0 %then %do;
    proc sql;
      insert into CTLINS.CTL_WATERMARK
        (
          pipeline_name,
          source_system_id,
          entity_name,
          last_success_ts,
          updated_ts
        )
      values
        (
          "&g_pipeline_name",
          "&g_source_system_default",
          "&entity_name",
          datetime(),
          datetime()
        );
    quit;
  %end;
%mend;

%if &g_has_error > 0 %then %let g_run_status=FAILED;
%else %let g_run_status=SUCCEEDED;

proc sql;
  update CTLINS.CTL_BATCH_RUN
  set
    run_end_ts = datetime(),
    run_status = "&g_run_status"
  where batch_run_id = &g_batch_run_id;
quit;

%if &g_run_status = SUCCEEDED %then %do;
  %_upsert_watermark(entity_name=CORE_PROVISION_TRANSACTION);
  %_upsert_watermark(entity_name=CORE_PAYOUT_TRANSACTION);
  %_upsert_watermark(entity_name=CORE_ADJUSTMENT_TRANSACTION);
%end;

%m_log_run(step_name=RUN_END, status=&g_run_status, rows_read=0, rows_written=1, rows_rejected=0);

%if &g_run_status = FAILED %then %do;
  %put ERROR: [CTL] Batch run failed with blocking DQ/reconciliation errors.;
  %abort cancel;
%end;
