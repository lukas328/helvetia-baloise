%macro m_recon_metric(
  metric_name=,
  recon_scope=DM,
  recon_grain=PERIOD,
  source_sql=,
  target_sql=,
  tolerance=0,
  fail_severity=ERROR
);
  %global g_has_error g_batch_run_id;
  %local l_source l_target l_variance l_abs_variance l_pass l_fail_severity;

  %let l_source=0;
  %let l_target=0;
  %let l_variance=0;
  %let l_abs_variance=0;
  %let l_fail_severity=%upcase(%superq(fail_severity));

  proc sql noprint;
    create table work._recon_src as
    &source_sql;

    create table work._recon_tgt as
    &target_sql;

    select coalesce(metric_value,0) into :l_source trimmed from work._recon_src;
    select coalesce(metric_value,0) into :l_target trimmed from work._recon_tgt;
  quit;

  %let l_variance=%sysevalf(&l_target - &l_source);
  %let l_abs_variance=%sysfunc(abs(%sysevalf(&l_variance)));

  %let l_pass=J;
  %if %sysevalf(&l_abs_variance > &tolerance) %then %let l_pass=N;

  proc sql noprint;
    insert into CTLINS.CTL_RECON_RESULT
      (
        batch_run_id,
        recon_scope,
        recon_metric,
        recon_grain,
        source_value,
        target_value,
        variance_value,
        tolerance_value,
        pass_flag,
        measured_ts
      )
    values
      (
        &g_batch_run_id,
        "%substr(%superq(recon_scope),1,40)",
        "%substr(%superq(metric_name),1,80)",
        "%substr(%superq(recon_grain),1,120)",
        &l_source,
        &l_target,
        &l_variance,
        &tolerance,
        "&l_pass",
        datetime()
      );
  quit;

  %if &l_pass = N and &l_fail_severity = ERROR %then %do;
    %let g_has_error=1;
    %put ERROR: [m_recon_metric] &metric_name failed. source=&l_source target=&l_target variance=&l_variance tolerance=&tolerance.;
  %end;
  %else %if &l_pass = N %then %do;
    %put WARNING: [m_recon_metric] &metric_name failed with non-blocking severity=&l_fail_severity.;
  %end;
  %else %do;
    %put NOTE: [m_recon_metric] &metric_name passed.;
  %end;
%mend;
