%macro m_log_run(step_name=, status=SUCCEEDED, rows_read=0, rows_written=0, rows_rejected=0, error_message=);
  %global g_batch_run_id g_step_order;
  %local l_status l_rows_read l_rows_written l_rows_rejected;

  %if %superq(g_batch_run_id)= or %superq(g_batch_run_id)=. %then %do;
    %put WARNING: [m_log_run] Batch run id is not set. Step log skipped for &step_name.;
    %return;
  %end;

  %let g_step_order=%eval(&g_step_order + 1);

  %let l_status=%upcase(%superq(status));
  %if &l_status ne RUNNING and &l_status ne SUCCEEDED and &l_status ne FAILED and &l_status ne SKIPPED %then %let l_status=SUCCEEDED;

  %let l_rows_read=&rows_read;
  %let l_rows_written=&rows_written;
  %let l_rows_rejected=&rows_rejected;

  %if %superq(l_rows_read)= or %superq(l_rows_read)=. %then %let l_rows_read=0;
  %if %superq(l_rows_written)= or %superq(l_rows_written)=. %then %let l_rows_written=0;
  %if %superq(l_rows_rejected)= or %superq(l_rows_rejected)=. %then %let l_rows_rejected=0;

  proc sql noprint;
    insert into CTLINS.CTL_BATCH_STEP
      (
        batch_run_id,
        step_name,
        step_order,
        step_start_ts,
        step_end_ts,
        step_status,
        rows_read,
        rows_written,
        rows_rejected,
        error_message
      )
    values
      (
        &g_batch_run_id,
        "%substr(%superq(step_name),1,80)",
        &g_step_order,
        datetime(),
        datetime(),
        "&l_status",
        &l_rows_read,
        &l_rows_written,
        &l_rows_rejected,
        "%substr(%superq(error_message),1,1000)"
      );
  quit;

  %put NOTE: [m_log_run] step=&step_name status=&l_status read=&l_rows_read written=&l_rows_written rejected=&l_rows_rejected;
%mend;
