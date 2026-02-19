%let l_step_name=MAP_DIM_ORG_KANAL_GRUND;

proc sql noprint;
  select count(*) into :l_rows_org trimmed from DWHCORE.CORE_ORG_UNIT where is_current='J';
  select count(*) into :l_rows_ch trimmed from DWHCORE.CORE_CHANNEL where is_current='J';
  select count(*) into :l_rows_reason trimmed from DWHCORE.CORE_REASON where is_current='J';

  select count(*) into :l_has_org_unknown trimmed from DMVERS.DIM_ORGANISATIONSEINHEIT where oe_code='UNK';
  select count(*) into :l_has_channel_unknown trimmed from DMVERS.DIM_VERTRIEBSKANAL where kanal_code='UNK';
  select count(*) into :l_has_reason_unknown trimmed from DMVERS.DIM_GRUND where grund_code='UNK';
quit;

%if &l_has_org_unknown = 0 %then %do;
  proc sql;
    insert into DMVERS.DIM_ORGANISATIONSEINHEIT
      (
        oe_code,
        oe_name,
        rechtseinheit,
        region
      )
    values
      (
        'UNK',
        'Unknown Org Unit',
        'Unknown',
        'Unknown'
      );
  quit;
%end;

%if &l_has_channel_unknown = 0 %then %do;
  proc sql;
    insert into DMVERS.DIM_VERTRIEBSKANAL
      (
        kanal_code,
        kanal_name
      )
    values
      (
        'UNK',
        'Unknown Channel'
      );
  quit;
%end;

%if &l_has_reason_unknown = 0 %then %do;
  proc sql;
    insert into DMVERS.DIM_GRUND
      (
        grund_code,
        grund_typ,
        grund_text
      )
    values
      (
        'UNK',
        'UNKNOWN',
        'Unknown Reason'
      );
  quit;
%end;

proc sql;
  update DMVERS.DIM_ORGANISATIONSEINHEIT t
  set
    oe_name = (select max(coalescec(s.org_unit_name, 'Unknown Org Unit')) from DWHCORE.CORE_ORG_UNIT s where s.org_unit_code=t.oe_code and s.is_current='J'),
    rechtseinheit = (select max(coalescec(s.legal_entity, 'Unknown')) from DWHCORE.CORE_ORG_UNIT s where s.org_unit_code=t.oe_code and s.is_current='J'),
    region = (select max(coalescec(s.region_code, 'Unknown')) from DWHCORE.CORE_ORG_UNIT s where s.org_unit_code=t.oe_code and s.is_current='J')
  where exists (select 1 from DWHCORE.CORE_ORG_UNIT s where s.org_unit_code=t.oe_code and s.is_current='J');
quit;

proc sql;
  insert into DMVERS.DIM_ORGANISATIONSEINHEIT
    (
      oe_code,
      oe_name,
      rechtseinheit,
      region
    )
  select
    s.org_unit_code,
    max(coalescec(s.org_unit_name, 'Unknown Org Unit')) as oe_name,
    max(coalescec(s.legal_entity, 'Unknown')) as rechtseinheit,
    max(coalescec(s.region_code, 'Unknown')) as region
  from DWHCORE.CORE_ORG_UNIT s
  where s.is_current='J'
    and s.org_unit_code is not null
    and not exists (select 1 from DMVERS.DIM_ORGANISATIONSEINHEIT t where t.oe_code=s.org_unit_code)
  group by s.org_unit_code;
quit;

proc sql;
  update DMVERS.DIM_VERTRIEBSKANAL t
  set
    kanal_name = (select max(coalescec(s.channel_name, 'Unknown Channel')) from DWHCORE.CORE_CHANNEL s where s.channel_code=t.kanal_code and s.is_current='J')
  where exists (select 1 from DWHCORE.CORE_CHANNEL s where s.channel_code=t.kanal_code and s.is_current='J');
quit;

proc sql;
  insert into DMVERS.DIM_VERTRIEBSKANAL
    (
      kanal_code,
      kanal_name
    )
  select
    s.channel_code,
    max(coalescec(s.channel_name, 'Unknown Channel')) as kanal_name
  from DWHCORE.CORE_CHANNEL s
  where s.is_current='J'
    and s.channel_code is not null
    and not exists (select 1 from DMVERS.DIM_VERTRIEBSKANAL t where t.kanal_code=s.channel_code)
  group by s.channel_code;
quit;

proc sql;
  update DMVERS.DIM_GRUND t
  set
    grund_typ = (select max(coalescec(s.reason_type_code, 'UNKNOWN')) from DWHCORE.CORE_REASON s where s.reason_code=t.grund_code and s.is_current='J'),
    grund_text = (select max(coalescec(s.reason_text, 'Unknown Reason')) from DWHCORE.CORE_REASON s where s.reason_code=t.grund_code and s.is_current='J')
  where exists (select 1 from DWHCORE.CORE_REASON s where s.reason_code=t.grund_code and s.is_current='J');
quit;

proc sql;
  insert into DMVERS.DIM_GRUND
    (
      grund_code,
      grund_typ,
      grund_text
    )
  select
    s.reason_code,
    max(coalescec(s.reason_type_code, 'UNKNOWN')) as grund_typ,
    max(coalescec(s.reason_text, 'Unknown Reason')) as grund_text
  from DWHCORE.CORE_REASON s
  where s.is_current='J'
    and s.reason_code is not null
    and not exists (select 1 from DMVERS.DIM_GRUND t where t.grund_code=s.reason_code)
  group by s.reason_code;
quit;

%let l_rows_src=%eval(&l_rows_org + &l_rows_ch + &l_rows_reason);
%m_log_run(step_name=&l_step_name, status=SUCCEEDED, rows_read=&l_rows_src, rows_written=&l_rows_src, rows_rejected=0);
