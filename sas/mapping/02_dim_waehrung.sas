%let l_step_name=MAP_DIM_WAEHRUNG;

proc sql noprint;
  select count(*) into :l_rows_src trimmed from DWHCORE.CORE_CURRENCY where is_current='J';
  select count(*) into :l_has_unknown trimmed from DMVERS.DIM_WAEHRUNG where waehrung_key='UNK';
quit;

%if &l_has_unknown = 0 %then %do;
  proc sql;
    insert into DMVERS.DIM_WAEHRUNG
      (
        waehrung_key,
        waehrung_name,
        reporting_flag
      )
    values
      (
        'UNK',
        'Unknown Currency',
        'N'
      );
  quit;
%end;

proc sql;
  update DMVERS.DIM_WAEHRUNG t
  set
    waehrung_name = (select max(c.currency_name) from DWHCORE.CORE_CURRENCY c where c.currency_key = t.waehrung_key and c.is_current='J'),
    reporting_flag = (select case when sum(case when c.is_reporting_currency='J' then 1 else 0 end) > 0 then 'J' else 'N' end from DWHCORE.CORE_CURRENCY c where c.currency_key = t.waehrung_key and c.is_current='J')
  where exists (select 1 from DWHCORE.CORE_CURRENCY c where c.currency_key = t.waehrung_key and c.is_current='J');
quit;

proc sql;
  insert into DMVERS.DIM_WAEHRUNG
    (
      waehrung_key,
      waehrung_name,
      reporting_flag
    )
  select
    c.currency_key,
    max(c.currency_name) as waehrung_name,
    case when sum(case when c.is_reporting_currency='J' then 1 else 0 end) > 0 then 'J' else 'N' end as reporting_flag
  from DWHCORE.CORE_CURRENCY c
  where c.is_current='J'
    and not exists (select 1 from DMVERS.DIM_WAEHRUNG t where t.waehrung_key = c.currency_key)
  group by c.currency_key;
quit;

%m_log_run(step_name=&l_step_name, status=SUCCEEDED, rows_read=&l_rows_src, rows_written=&l_rows_src, rows_rejected=0);
