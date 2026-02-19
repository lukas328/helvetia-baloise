%put NOTE: [CTL] Start batch run for sales provisioning data mart load.;

%let g_step_order=0;
%let g_has_error=0;
%let g_run_status=RUNNING;

proc sql;
  insert into CTLINS.CTL_BATCH_RUN
    (
      pipeline_name,
      trigger_type,
      source_cutoff_ts,
      run_start_ts,
      run_status,
      initiated_by
    )
  values
    (
      "&g_pipeline_name",
      "&g_trigger_type",
      datetime(),
      datetime(),
      "RUNNING",
      "&sysuserid"
    );
quit;

proc sql noprint;
  select max(batch_run_id)
  into :g_batch_run_id trimmed
  from CTLINS.CTL_BATCH_RUN
  where pipeline_name = "&g_pipeline_name"
    and initiated_by = "&sysuserid";
quit;

%m_log_run(step_name=RUN_START, status=SUCCEEDED, rows_read=0, rows_written=1, rows_rejected=0);
