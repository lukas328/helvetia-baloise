%macro m_dq_assert(
  check_name=,
  sql_expr=,
  layer_name=DM,
  entity_name=GENERAL,
  severity=ERROR,
  fail_threshold=0
);
  %global g_has_error g_batch_run_id;
  %local l_failed l_tested l_pass l_severity l_rule;

  %let l_failed=0;
  %let l_tested=0;
  %let l_severity=%upcase(%superq(severity));
  %let l_rule=%substr(%superq(check_name),1,30);

  proc sql noprint;
    create table work._dq_eval as
    &sql_expr;

    select
      coalesce(tested_rows,0),
      coalesce(failed_rows,0)
    into
      :l_tested trimmed,
      :l_failed trimmed
    from work._dq_eval;
  quit;

  %let l_pass=J;
  %if %sysevalf(&l_failed > &fail_threshold) %then %let l_pass=N;

  proc sql noprint;
    insert into CTLINS.CTL_DQ_RESULT
      (
        batch_run_id,
        layer_name,
        entity_name,
        dq_rule_id,
        severity,
        tested_rows,
        failed_rows,
        pass_flag,
        measured_ts
      )
    values
      (
        &g_batch_run_id,
        "%substr(%superq(layer_name),1,20)",
        "%substr(%superq(entity_name),1,80)",
        "&l_rule",
        "%substr(&l_severity,1,10)",
        &l_tested,
        &l_failed,
        "&l_pass",
        datetime()
      );
  quit;

  %if &l_pass = N and &l_severity = ERROR %then %do;
    %let g_has_error=1;
    %put ERROR: [m_dq_assert] &check_name failed. failed_rows=&l_failed threshold=&fail_threshold.;
  %end;
  %else %if &l_pass = N %then %do;
    %put WARNING: [m_dq_assert] &check_name failed with non-blocking severity=&l_severity.;
  %end;
  %else %do;
    %put NOTE: [m_dq_assert] &check_name passed. tested_rows=&l_tested.;
  %end;
%mend;
