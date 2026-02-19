%let l_step_name=MAP_DIM_VERMITTLER;

proc sql noprint;
  select count(*) into :l_rows_src trimmed
  from DWHCORE.CORE_PARTY_ROLE
  where upcase(role_type_code) in ('AGENT','BROKER','VERMITTLER');

  select count(*) into :l_has_unknown trimmed
  from DMVERS.DIM_VERMITTLER
  where vermittler_nummer='UNK'
    and gueltig_von='01JAN1900'd;
quit;

%if &l_has_unknown = 0 %then %do;
  proc sql;
    insert into DMVERS.DIM_VERMITTLER
      (
        vermittler_nummer,
        vollname,
        vermittler_typ,
        status_code,
        eintrittsdatum,
        austrittsdatum,
        gueltig_von,
        gueltig_bis,
        ist_aktuell
      )
    values
      (
        'UNK',
        'Unknown Agent',
        'UNKNOWN',
        'ACTIVE',
        '01JAN1900'd,
        .,
        '01JAN1900'd,
        '31DEC9999'd,
        'J'
      );
  quit;
%end;

proc sql;
  create table work.src_dim_vermittler as
  select distinct
    coalescec(strip(pr.role_identifier), cats('SRC-',strip(p.source_party_id))) as vermittler_nummer length=40,
    coalescec(strip(p.full_name), strip(p.legal_name), 'Unknown Agent') as vollname length=150,
    pr.role_type_code as vermittler_typ length=30,
    'ACTIVE' as status_code length=20,
    case when p.valid_from > pr.valid_from then p.valid_from else pr.valid_from end as eintrittsdatum,
    case
      when (case when p.valid_to < pr.valid_to then p.valid_to else pr.valid_to end) < '31DEC9999'd
      then (case when p.valid_to < pr.valid_to then p.valid_to else pr.valid_to end)
      else .
    end as austrittsdatum,
    case when p.valid_from > pr.valid_from then p.valid_from else pr.valid_from end as gueltig_von,
    case when p.valid_to < pr.valid_to then p.valid_to else pr.valid_to end as gueltig_bis,
    case when p.is_current='J' and pr.is_current='J' then 'J' else 'N' end as ist_aktuell length=1
  from DWHCORE.CORE_PARTY_ROLE pr
  join DWHCORE.CORE_PARTY p
    on p.party_key = pr.party_key
  where upcase(pr.role_type_code) in ('AGENT','BROKER','VERMITTLER');
quit;

%m_scd2_merge(
  src_ds=work.src_dim_vermittler,
  tgt_ds=DMVERS.DIM_VERMITTLER,
  bk_cols=vermittler_nummer,
  hash_cols=vollname vermittler_typ status_code eintrittsdatum austrittsdatum gueltig_bis ist_aktuell,
  valid_from_col=gueltig_von
);

%m_log_run(step_name=&l_step_name, status=SUCCEEDED, rows_read=&l_rows_src, rows_written=&l_rows_src, rows_rejected=0);
