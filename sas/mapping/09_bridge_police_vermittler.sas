%let l_step_name=MAP_BR_POLICE_VERMITTLER;

proc sql noprint;
  select coalesce(max(vermittler_key),1) into :l_unk_vermittler_key trimmed
  from DMVERS.DIM_VERMITTLER
  where vermittler_nummer='UNK'
    and ist_aktuell='J';
quit;

%if %length(&l_unk_vermittler_key)=0 %then %let l_unk_vermittler_key=1;

proc sql;
  create table work.src_br_pol_verm_raw as
  select
    dp.police_key,
    coalesce(dv.vermittler_key, &l_unk_vermittler_key) as vermittler_key,
    a.valid_from as gueltig_von,
    a.valid_to as gueltig_bis,
    case
      when s.split_sum between 99.5 and 100.5 then round((coalesce(a.credit_split_percent,0) * 100) / s.split_sum, 0.01)
      else .
    end as aufteilungsquote_prozent,
    coalescec(a.assignment_type_code,'UNKNOWN') as bezugsrolle length=40,
    s.split_sum
  from DWHCORE.CORE_POLICY_AGENT_ASSIGNMENT a
  join DWHCORE.CORE_POLICY cp
    on cp.policy_key = a.policy_key
  join DMVERS.DIM_POLICE dp
    on dp.policenummer = cp.policy_number
   and a.valid_from between dp.gueltig_von and dp.gueltig_bis
  left join DWHCORE.CORE_PARTY_ROLE pr
    on pr.party_role_key = a.agent_party_role_key
  left join DWHCORE.CORE_PARTY pa
    on pa.party_key = pr.party_key
  left join DMVERS.DIM_VERMITTLER dv
    on dv.vermittler_nummer = coalescec(strip(pr.role_identifier), cats('SRC-',strip(pa.source_party_id)))
   and a.valid_from between dv.gueltig_von and dv.gueltig_bis
  left join (
    select
      policy_key,
      valid_from,
      sum(coalesce(credit_split_percent,0)) as split_sum
    from DWHCORE.CORE_POLICY_AGENT_ASSIGNMENT
    group by policy_key, valid_from
  ) s
    on s.policy_key = a.policy_key
   and s.valid_from = a.valid_from;
quit;

data work.src_br_pol_verm;
  set work.src_br_pol_verm_raw;
  if 99.5 <= split_sum <= 100.5;
  if aufteilungsquote_prozent > 0;
  drop split_sum;
run;

proc sql noprint;
  select count(*) into :l_rows_raw trimmed from work.src_br_pol_verm_raw;
  select count(*) into :l_rows_src trimmed from work.src_br_pol_verm;
quit;

%let l_rows_rejected=%eval(&l_rows_raw - &l_rows_src);

proc sql;
  delete from DMVERS.BR_POLICE_VERMITTLER_AUFTEILUNG;
quit;

proc append base=DMVERS.BR_POLICE_VERMITTLER_AUFTEILUNG data=work.src_br_pol_verm force;
run;

%m_log_run(step_name=&l_step_name, status=SUCCEEDED, rows_read=&l_rows_raw, rows_written=&l_rows_src, rows_rejected=&l_rows_rejected);
