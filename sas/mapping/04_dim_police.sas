%let l_step_name=MAP_DIM_POLICE;

proc sql noprint;
  select count(*) into :l_rows_src trimmed from DWHCORE.CORE_POLICY;
  select count(*) into :l_has_unknown trimmed
  from DMVERS.DIM_POLICE
  where policenummer='UNKNOWN'
    and gueltig_von='01JAN1900'd;
quit;

%if &l_has_unknown = 0 %then %do;
  proc sql;
    insert into DMVERS.DIM_POLICE
      (
        policenummer,
        kundensegment,
        vertragsbeginn,
        vertragsende,
        status_code,
        gueltig_von,
        gueltig_bis,
        ist_aktuell
      )
    values
      (
        'UNKNOWN',
        'UNKNOWN',
        '01JAN1900'd,
        '31DEC9999'd,
        'UNKNOWN',
        '01JAN1900'd,
        '31DEC9999'd,
        'J'
      );
  quit;
%end;

proc sql;
  create table work.src_dim_police as
  select distinct
    cp.policy_number as policenummer length=50,
    'UNKNOWN' as kundensegment length=50,
    cp.inception_date as vertragsbeginn,
    cp.expiry_date as vertragsende,
    coalescec(cp.policy_status_code,'UNKNOWN') as status_code length=20,
    cp.valid_from as gueltig_von,
    cp.valid_to as gueltig_bis,
    case when cp.is_current='J' then 'J' else 'N' end as ist_aktuell length=1
  from DWHCORE.CORE_POLICY cp
  where cp.policy_number is not null;
quit;

%m_scd2_merge(
  src_ds=work.src_dim_police,
  tgt_ds=DMVERS.DIM_POLICE,
  bk_cols=policenummer,
  hash_cols=kundensegment vertragsbeginn vertragsende status_code gueltig_bis ist_aktuell,
  valid_from_col=gueltig_von
);

%m_log_run(step_name=&l_step_name, status=SUCCEEDED, rows_read=&l_rows_src, rows_written=&l_rows_src, rows_rejected=0);
