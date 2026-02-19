%let l_step_name=MAP_FKT_PROVISIONSANPASSUNG;

proc sql noprint;
  select coalesce(max(vermittler_key),1) into :l_unk_vermittler_key trimmed
  from DMVERS.DIM_VERMITTLER
  where vermittler_nummer='UNK'
    and ist_aktuell='J';

  select coalesce(max(grund_key),1) into :l_unk_grund_key trimmed
  from DMVERS.DIM_GRUND
  where grund_code='UNK';

  select count(*) into :l_rows_raw trimmed
  from DWHCORE.CORE_ADJUSTMENT_TRANSACTION
  where adjustment_date_key >= &g_min_event_date;
quit;

proc sql;
  create table work.src_fkt_anpassung_raw as
  select
    fe.provisionsereignis_key,
    coalesce(dv.vermittler_key, &l_unk_vermittler_key) as vermittler_key,
    coalesce(at.adjustment_date_key, 19000101) as anpassungsdatum_key,
    coalesce(dg.grund_key, &l_unk_grund_key) as grund_key,
    coalescec(dw.waehrung_key, 'UNK') as waehrung_key length=3,
    substr(at.source_adjustment_id,1,64) as anpassung_id length=64,
    coalesce(at.adjustment_amount,0) as anpassung_betrag,
    coalesce(
      fx_exact.fx_rate,
      fx_fb.fx_rate,
      case when at.currency_key = "&g_reporting_ccy" then 1 else . end
    ) as fx_kurs
  from DWHCORE.CORE_ADJUSTMENT_TRANSACTION at
  left join DWHCORE.CORE_PROVISION_TRANSACTION pt
    on pt.provision_txn_key = at.provision_txn_key
  left join DWHCORE.CORE_PREMIUM_TRANSACTION pmt
    on pmt.premium_txn_key = pt.premium_txn_key
  left join DWHCORE.CORE_DATE d_adj
    on d_adj.date_key = at.adjustment_date_key
  left join DWHCORE.CORE_PARTY_ROLE pr
    on pr.party_role_key = at.agent_party_role_key
  left join DWHCORE.CORE_PARTY pa
    on pa.party_key = pr.party_key
  left join DWHCORE.CORE_REASON cr
    on cr.reason_key = at.reason_key
  left join DMVERS.DIM_VERMITTLER dv
    on dv.vermittler_nummer = coalescec(strip(pr.role_identifier), cats('SRC-',strip(pa.source_party_id)))
   and d_adj.calendar_date between dv.gueltig_von and dv.gueltig_bis
  left join DMVERS.DIM_GRUND dg
    on dg.grund_code = cr.reason_code
  left join DMVERS.DIM_WAEHRUNG dw
    on dw.waehrung_key = at.currency_key
  left join DWHCORE.CORE_FX_RATE fx_exact
    on fx_exact.from_currency_key = at.currency_key
   and fx_exact.to_currency_key = "&g_reporting_ccy"
   and fx_exact.rate_date_key = at.adjustment_date_key
  left join DWHCORE.CORE_FX_RATE fx_fb
    on fx_fb.from_currency_key = at.currency_key
   and fx_fb.to_currency_key = "&g_reporting_ccy"
   and fx_fb.rate_date_key = (
      select max(fx2.rate_date_key)
      from DWHCORE.CORE_FX_RATE fx2
      join DWHCORE.CORE_DATE d2
        on d2.date_key = fx2.rate_date_key
      where fx2.from_currency_key = at.currency_key
        and fx2.to_currency_key = "&g_reporting_ccy"
        and d2.calendar_date < d_adj.calendar_date
        and d2.calendar_date >= (d_adj.calendar_date - 5)
    )
  left join DMVERS.FKT_VERTRIEBSPROVISIONSEREIGNIS fe
    on fe.quell_system_id = pt.source_system_id
   and fe.praemientransaktion_id = pmt.source_premium_txn_id
   and fe.vermittler_key = coalesce(dv.vermittler_key, &l_unk_vermittler_key)
   and fe.abgrenzungsdatum_key = coalesce(pt.event_effective_date_key, 19000101)
   and fe.abrechnungsperiode = coalescec(
     pt.accrual_period,
     cats(substr(put(coalesce(pt.event_effective_date_key,19000101), z8.),1,4), '-', substr(put(coalesce(pt.event_effective_date_key,19000101), z8.),5,2))
   )
  where at.adjustment_date_key >= &g_min_event_date;
quit;

data work.src_fkt_anpassung;
  set work.src_fkt_anpassung_raw;
  if missing(provisionsereignis_key) then delete;
  if missing(fx_kurs) and waehrung_key ne "&g_reporting_ccy" then delete;
  anpassung_report_ccy = round(anpassung_betrag * fx_kurs, 0.01);
run;

proc sql noprint;
  select count(*) into :l_rows_src trimmed from work.src_fkt_anpassung;
quit;

%let l_rows_rejected=%eval(&l_rows_raw - &l_rows_src);

%m_fact_upsert(
  src_ds=work.src_fkt_anpassung,
  tgt_ds=DMVERS.FKT_PROVISIONSANPASSUNG,
  natural_key_cols=anpassung_id
);

%m_log_run(
  step_name=&l_step_name,
  status=SUCCEEDED,
  rows_read=&l_rows_raw,
  rows_written=&g_last_rows_written,
  rows_rejected=&l_rows_rejected
);
