%let l_step_name=MAP_DIM_DATUM;

proc sql noprint;
  select count(*) into :l_rows_src trimmed from DWHCORE.CORE_DATE;
  select count(*) into :l_has_unknown trimmed from DMVERS.DIM_DATUM where datum_key = 19000101;
quit;

%if &l_has_unknown = 0 %then %do;
  proc sql;
    insert into DMVERS.DIM_DATUM
      (
        datum_key,
        datum,
        jahr,
        quartal,
        monat,
        kalenderwoche,
        tag_im_monat,
        ist_monatsende
      )
    values
      (
        19000101,
        '01JAN1900'd,
        1900,
        1,
        1,
        1,
        1,
        'N'
      );
  quit;
%end;

proc sql;
  update DMVERS.DIM_DATUM t
  set
    datum = (select s.calendar_date from DWHCORE.CORE_DATE s where s.date_key = t.datum_key),
    jahr = (select s.year_num from DWHCORE.CORE_DATE s where s.date_key = t.datum_key),
    quartal = (select s.quarter_num from DWHCORE.CORE_DATE s where s.date_key = t.datum_key),
    monat = (select s.month_num from DWHCORE.CORE_DATE s where s.date_key = t.datum_key),
    kalenderwoche = (select s.week_num from DWHCORE.CORE_DATE s where s.date_key = t.datum_key),
    tag_im_monat = (select s.day_num from DWHCORE.CORE_DATE s where s.date_key = t.datum_key),
    ist_monatsende = (select case when s.is_month_end='J' then 'J' else 'N' end from DWHCORE.CORE_DATE s where s.date_key = t.datum_key)
  where exists (select 1 from DWHCORE.CORE_DATE s where s.date_key = t.datum_key);
quit;

proc sql;
  insert into DMVERS.DIM_DATUM
    (
      datum_key,
      datum,
      jahr,
      quartal,
      monat,
      kalenderwoche,
      tag_im_monat,
      ist_monatsende
    )
  select
    s.date_key,
    s.calendar_date,
    s.year_num,
    s.quarter_num,
    s.month_num,
    s.week_num,
    s.day_num,
    case when s.is_month_end='J' then 'J' else 'N' end
  from DWHCORE.CORE_DATE s
  where not exists (select 1 from DMVERS.DIM_DATUM t where t.datum_key = s.date_key);
quit;

%m_log_run(step_name=&l_step_name, status=SUCCEEDED, rows_read=&l_rows_src, rows_written=&l_rows_src, rows_rejected=0);
