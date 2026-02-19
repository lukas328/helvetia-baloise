%let l_step_name=MAP_DIM_PROVISIONSPLAN;

proc sql noprint;
  select count(*) into :l_rows_src trimmed from DWHCORE.CORE_COMMISSION_PLAN;
  select count(*) into :l_has_unknown trimmed
  from DMVERS.DIM_PROVISIONSPLAN
  where plan_code='UNK'
    and gueltig_von='01JAN1900'd;
quit;

%if &l_has_unknown = 0 %then %do;
  proc sql;
    insert into DMVERS.DIM_PROVISIONSPLAN
      (
        plan_code,
        plan_name,
        provisionsmodell,
        gueltig_von,
        gueltig_bis,
        ist_aktuell
      )
    values
      (
        'UNK',
        'Unknown Plan',
        'UNKNOWN',
        '01JAN1900'd,
        '31DEC9999'd,
        'J'
      );
  quit;
%end;

proc sql;
  create table work.src_dim_plan as
  select distinct
    cp.plan_code as plan_code length=40,
    coalescec(cp.plan_name,'Unknown Plan') as plan_name length=120,
    coalescec(cp.model_type_code,'UNKNOWN') as provisionsmodell length=40,
    cp.valid_from as gueltig_von,
    cp.valid_to as gueltig_bis,
    case when cp.is_current='J' then 'J' else 'N' end as ist_aktuell length=1
  from DWHCORE.CORE_COMMISSION_PLAN cp
  where cp.plan_code is not null;
quit;

%m_scd2_merge(
  src_ds=work.src_dim_plan,
  tgt_ds=DMVERS.DIM_PROVISIONSPLAN,
  bk_cols=plan_code,
  hash_cols=plan_name provisionsmodell gueltig_bis ist_aktuell,
  valid_from_col=gueltig_von
);

%m_log_run(step_name=&l_step_name, status=SUCCEEDED, rows_read=&l_rows_src, rows_written=&l_rows_src, rows_rejected=0);
