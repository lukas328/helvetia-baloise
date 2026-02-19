%let l_step_name=MAP_DIM_PRODUKT;

proc sql noprint;
  select count(*) into :l_rows_src trimmed from DWHCORE.CORE_PRODUCT;
  select count(*) into :l_has_unknown trimmed
  from DMVERS.DIM_PRODUKT
  where produkt_code='UNK'
    and gueltig_von='01JAN1900'd;
quit;

%if &l_has_unknown = 0 %then %do;
  proc sql;
    insert into DMVERS.DIM_PRODUKT
      (
        produkt_code,
        produkt_name,
        sparte,
        tarif,
        gueltig_von,
        gueltig_bis,
        ist_aktuell
      )
    values
      (
        'UNK',
        'Unknown Product',
        'UNKNOWN',
        'UNKNOWN',
        '01JAN1900'd,
        '31DEC9999'd,
        'J'
      );
  quit;
%end;

proc sql;
  create table work.src_dim_produkt as
  select distinct
    cp.product_code as produkt_code length=40,
    coalescec(cp.product_name,'Unknown Product') as produkt_name length=120,
    coalescec(cp.line_of_business,'UNKNOWN') as sparte length=50,
    coalescec(cp.tariff_code,'UNKNOWN') as tarif length=50,
    cp.valid_from as gueltig_von,
    cp.valid_to as gueltig_bis,
    case when cp.is_current='J' then 'J' else 'N' end as ist_aktuell length=1
  from DWHCORE.CORE_PRODUCT cp
  where cp.product_code is not null;
quit;

%m_scd2_merge(
  src_ds=work.src_dim_produkt,
  tgt_ds=DMVERS.DIM_PRODUKT,
  bk_cols=produkt_code,
  hash_cols=produkt_name sparte tarif gueltig_bis ist_aktuell,
  valid_from_col=gueltig_von
);

%m_log_run(step_name=&l_step_name, status=SUCCEEDED, rows_read=&l_rows_src, rows_written=&l_rows_src, rows_rejected=0);
