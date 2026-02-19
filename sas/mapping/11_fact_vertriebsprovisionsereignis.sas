%let l_step_name=MAP_FKT_VERTRIEBSPROVISIONSEREIGNIS;

proc sql noprint;
  select coalesce(max(police_key),1) into :l_unk_police_key trimmed
  from DMVERS.DIM_POLICE
  where policenummer='UNKNOWN'
    and ist_aktuell='J';

  select coalesce(max(produkt_key),1) into :l_unk_produkt_key trimmed
  from DMVERS.DIM_PRODUKT
  where produkt_code='UNK'
    and ist_aktuell='J';

  select coalesce(max(vermittler_key),1) into :l_unk_vermittler_key trimmed
  from DMVERS.DIM_VERMITTLER
  where vermittler_nummer='UNK'
    and ist_aktuell='J';

  select coalesce(max(vertriebskanal_key),1) into :l_unk_kanal_key trimmed
  from DMVERS.DIM_VERTRIEBSKANAL
  where kanal_code='UNK';

  select coalesce(max(provisionsplan_key),1) into :l_unk_plan_key trimmed
  from DMVERS.DIM_PROVISIONSPLAN
  where plan_code='UNK'
    and ist_aktuell='J';

  select coalesce(max(provisionsregel_key),1) into :l_unk_regel_key trimmed
  from DMVERS.DIM_PROVISIONSREGEL
  where regel_code='UNK'
    and ist_aktuell='J';

  select coalesce(max(organisationseinheit_key),1) into :l_unk_oe_key trimmed
  from DMVERS.DIM_ORGANISATIONSEINHEIT
  where oe_code='UNK';

  select count(*) into :l_rows_raw trimmed
  from DWHCORE.CORE_PROVISION_TRANSACTION
  where event_effective_date_key >= &g_min_event_date;
quit;

proc sql;
  create table work.src_fkt_vpe_raw as
  select
    coalesce(dp.police_key, &l_unk_police_key) as police_key,
    coalesce(dprod.produkt_key, &l_unk_produkt_key) as produkt_key,
    coalesce(dv.vermittler_key, &l_unk_vermittler_key) as vermittler_key,
    coalesce(dch.vertriebskanal_key, &l_unk_kanal_key) as vertriebskanal_key,
    coalesce(dpl.provisionsplan_key, &l_unk_plan_key) as provisionsplan_key,
    coalesce(drl.provisionsregel_key, &l_unk_regel_key) as provisionsregel_key,
    coalesce(doe.organisationseinheit_key, &l_unk_oe_key) as organisationseinheit_key,
    coalescec(dw.waehrung_key, 'UNK') as waehrung_key length=3,
    coalesce(pt.event_effective_date_key, 19000101) as abgrenzungsdatum_key,
    coalesce(pmt.booking_date_key, 19000101) as buchungsdatum_key,
    cp.policy_number as policenummer length=50,
    substr(pmt.source_premium_txn_id,1,64) as praemientransaktion_id length=64,
    pt.source_system_id as quell_system_id length=40,
    coalescec(
      pt.accrual_period,
      cats(substr(put(coalesce(pt.event_effective_date_key,19000101), z8.),1,4), '-', substr(put(coalesce(pt.event_effective_date_key,19000101), z8.),5,2))
    ) as abrechnungsperiode length=7,
    coalesce(pmt.gross_amount,0) as bruttopraemie_betrag,
    coalesce(pt.provision_base_amount, coalesce(pmt.net_amount, pmt.gross_amount, 0)) as provisionsbasis_betrag,
    coalesce(pt.provision_rate,0) as provisionssatz,
    coalesce(pt.gross_provision_amount, calculated provisionsbasis_betrag * calculated provisionssatz) as brutto_provision_betrag,
    coalesce(pt.clawback_amount,0) as stornohaftung_betrag,
    coalesce(pt.tax_amount,0) as steuer_betrag,
    coalesce(pt.net_provision_amount, calculated brutto_provision_betrag - calculated stornohaftung_betrag - calculated steuer_betrag) as netto_provision_betrag,
    coalesce(
      fx_exact.fx_rate,
      fx_fb.fx_rate,
      case when pt.currency_key = "&g_reporting_ccy" then 1 else . end
    ) as fx_kurs
  from DWHCORE.CORE_PROVISION_TRANSACTION pt
  join DWHCORE.CORE_PREMIUM_TRANSACTION pmt
    on pmt.premium_txn_key = pt.premium_txn_key
  join DWHCORE.CORE_POLICY cp
    on cp.policy_key = pt.policy_key
  left join DWHCORE.CORE_PRODUCT cprod
    on cprod.product_key = cp.product_key
  left join DWHCORE.CORE_DATE d_evt
    on d_evt.date_key = pt.event_effective_date_key
  left join DWHCORE.CORE_PARTY_ROLE pr
    on pr.party_role_key = pt.agent_party_role_key
  left join DWHCORE.CORE_PARTY pa
    on pa.party_key = pr.party_key
  left join DWHCORE.CORE_CHANNEL cch
    on cch.channel_key = pt.channel_key
  left join DWHCORE.CORE_ORG_UNIT cou
    on cou.org_unit_key = pt.org_unit_key
  left join DWHCORE.CORE_COMMISSION_PLAN cpl
    on cpl.commission_plan_key = pt.commission_plan_key
  left join DWHCORE.CORE_COMMISSION_RULE cr
    on cr.commission_rule_key = pt.commission_rule_key
  left join DMVERS.DIM_POLICE dp
    on dp.policenummer = cp.policy_number
   and d_evt.calendar_date between dp.gueltig_von and dp.gueltig_bis
  left join DMVERS.DIM_PRODUKT dprod
    on dprod.produkt_code = cprod.product_code
   and d_evt.calendar_date between dprod.gueltig_von and dprod.gueltig_bis
  left join DMVERS.DIM_VERMITTLER dv
    on dv.vermittler_nummer = coalescec(strip(pr.role_identifier), cats('SRC-',strip(pa.source_party_id)))
   and d_evt.calendar_date between dv.gueltig_von and dv.gueltig_bis
  left join DMVERS.DIM_VERTRIEBSKANAL dch
    on dch.kanal_code = cch.channel_code
  left join DMVERS.DIM_ORGANISATIONSEINHEIT doe
    on doe.oe_code = cou.org_unit_code
  left join DMVERS.DIM_PROVISIONSPLAN dpl
    on dpl.plan_code = cpl.plan_code
   and d_evt.calendar_date between dpl.gueltig_von and dpl.gueltig_bis
  left join DMVERS.DIM_PROVISIONSREGEL drl
    on drl.regel_code = cr.rule_code
   and d_evt.calendar_date between drl.gueltig_von and drl.gueltig_bis
  left join DMVERS.DIM_WAEHRUNG dw
    on dw.waehrung_key = pt.currency_key
  left join DWHCORE.CORE_FX_RATE fx_exact
    on fx_exact.from_currency_key = pt.currency_key
   and fx_exact.to_currency_key = "&g_reporting_ccy"
   and fx_exact.rate_date_key = pt.event_effective_date_key
  left join DWHCORE.CORE_FX_RATE fx_fb
    on fx_fb.from_currency_key = pt.currency_key
   and fx_fb.to_currency_key = "&g_reporting_ccy"
   and fx_fb.rate_date_key = (
      select max(fx2.rate_date_key)
      from DWHCORE.CORE_FX_RATE fx2
      join DWHCORE.CORE_DATE d2
        on d2.date_key = fx2.rate_date_key
      where fx2.from_currency_key = pt.currency_key
        and fx2.to_currency_key = "&g_reporting_ccy"
        and d2.calendar_date < d_evt.calendar_date
        and d2.calendar_date >= (d_evt.calendar_date - 5)
    )
  where pt.event_effective_date_key >= &g_min_event_date;
quit;

data work.src_fkt_vpe;
  set work.src_fkt_vpe_raw;
  if missing(fx_kurs) and waehrung_key ne "&g_reporting_ccy" then delete;
  netto_provision_report_ccy = round(netto_provision_betrag * fx_kurs, 0.01);
run;

proc sql noprint;
  select count(*) into :l_rows_src trimmed from work.src_fkt_vpe;
quit;

%let l_rows_rejected=%eval(&l_rows_raw - &l_rows_src);

%m_fact_upsert(
  src_ds=work.src_fkt_vpe,
  tgt_ds=DMVERS.FKT_VERTRIEBSPROVISIONSEREIGNIS,
  natural_key_cols=quell_system_id praemientransaktion_id vermittler_key abrechnungsperiode abgrenzungsdatum_key
);

%m_log_run(
  step_name=&l_step_name,
  status=SUCCEEDED,
  rows_read=&l_rows_raw,
  rows_written=&g_last_rows_written,
  rows_rejected=&l_rows_rejected
);
