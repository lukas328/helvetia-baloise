%let l_step_name=MAP_BR_VERMITTLER_HIERARCHIE;

proc sql noprint;
  select coalesce(max(vermittler_key),1) into :l_unk_vermittler_key trimmed
  from DMVERS.DIM_VERMITTLER
  where vermittler_nummer='UNK'
    and ist_aktuell='J';
quit;

%if %length(&l_unk_vermittler_key)=0 %then %let l_unk_vermittler_key=1;

proc sql;
  create table work.src_br_hier_raw as
  select distinct
    coalesce(dv_sub.vermittler_key, &l_unk_vermittler_key) as unterstellter_vermittler_key,
    coalesce(dv_sup.vermittler_key, &l_unk_vermittler_key) as vorgesetzter_vermittler_key,
    a.valid_from as gueltig_von,
    a.valid_to as gueltig_bis,
    1 as ebene
  from DWHCORE.CORE_POLICY_AGENT_ASSIGNMENT a
  left join DWHCORE.CORE_PARTY_ROLE pr_sub
    on pr_sub.party_role_key = a.agent_party_role_key
  left join DWHCORE.CORE_PARTY p_sub
    on p_sub.party_key = pr_sub.party_key
  left join DWHCORE.CORE_PARTY_ROLE pr_sup
    on pr_sup.party_role_key = a.supervisor_party_role_key
  left join DWHCORE.CORE_PARTY p_sup
    on p_sup.party_key = pr_sup.party_key
  left join DMVERS.DIM_VERMITTLER dv_sub
    on dv_sub.vermittler_nummer = coalescec(strip(pr_sub.role_identifier), cats('SRC-',strip(p_sub.source_party_id)))
   and a.valid_from between dv_sub.gueltig_von and dv_sub.gueltig_bis
  left join DMVERS.DIM_VERMITTLER dv_sup
    on dv_sup.vermittler_nummer = coalescec(strip(pr_sup.role_identifier), cats('SRC-',strip(p_sup.source_party_id)))
   and a.valid_from between dv_sup.gueltig_von and dv_sup.gueltig_bis
  where a.agent_party_role_key is not null;
quit;

data work.src_br_hier;
  set work.src_br_hier_raw;
  if unterstellter_vermittler_key ne vorgesetzter_vermittler_key;
run;

proc sql noprint;
  select count(*) into :l_rows_raw trimmed from work.src_br_hier_raw;
  select count(*) into :l_rows_src trimmed from work.src_br_hier;
quit;

%let l_rows_rejected=%eval(&l_rows_raw - &l_rows_src);

proc sql;
  delete from DMVERS.BR_VERMITTLER_HIERARCHIE;
quit;

proc append base=DMVERS.BR_VERMITTLER_HIERARCHIE data=work.src_br_hier force;
run;

%m_log_run(step_name=&l_step_name, status=SUCCEEDED, rows_read=&l_rows_raw, rows_written=&l_rows_src, rows_rejected=&l_rows_rejected);
