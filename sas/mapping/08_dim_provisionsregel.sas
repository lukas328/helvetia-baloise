%let l_step_name=MAP_DIM_PROVISIONSREGEL;

proc sql noprint;
  select count(*) into :l_rows_src trimmed from DWHCORE.CORE_COMMISSION_RULE;
  select count(*) into :l_has_unknown trimmed
  from DMVERS.DIM_PROVISIONSREGEL
  where regel_code='UNK'
    and gueltig_von='01JAN1900'd;
quit;

%if &l_has_unknown = 0 %then %do;
  proc sql;
    insert into DMVERS.DIM_PROVISIONSREGEL
      (
        regel_code,
        ereignistyp,
        beschreibung,
        clawback_monate,
        gueltig_von,
        gueltig_bis,
        ist_aktuell
      )
    values
      (
        'UNK',
        'UNKNOWN',
        'Unknown Rule',
        0,
        '01JAN1900'd,
        '31DEC9999'd,
        'J'
      );
  quit;
%end;

proc sql;
  create table work.src_dim_regel as
  select distinct
    cr.rule_code as regel_code length=40,
    coalescec(cr.event_type_code,'UNKNOWN') as ereignistyp length=30,
    substr(catx(' | ',
      cats('BASE=',coalescec(cr.base_type_code,'NA')),
      cats('SRC_RULE=',coalescec(cr.source_rule_id,'NA'))
    ),1,300) as beschreibung length=300,
    coalesce(cr.clawback_months,0) as clawback_monate,
    cr.valid_from as gueltig_von,
    cr.valid_to as gueltig_bis,
    case when cr.is_current='J' then 'J' else 'N' end as ist_aktuell length=1
  from DWHCORE.CORE_COMMISSION_RULE cr
  where cr.rule_code is not null;
quit;

%m_scd2_merge(
  src_ds=work.src_dim_regel,
  tgt_ds=DMVERS.DIM_PROVISIONSREGEL,
  bk_cols=regel_code,
  hash_cols=ereignistyp beschreibung clawback_monate gueltig_bis ist_aktuell,
  valid_from_col=gueltig_von
);

%m_log_run(step_name=&l_step_name, status=SUCCEEDED, rows_read=&l_rows_src, rows_written=&l_rows_src, rows_rejected=0);
