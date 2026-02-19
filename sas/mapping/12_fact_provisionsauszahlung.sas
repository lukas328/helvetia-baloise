%let l_step_name=MAP_FKT_PROVISIONSAUSZAHLUNG;

proc sql noprint;
  select coalesce(max(vermittler_key),1) into :l_unk_vermittler_key trimmed
  from DMVERS.DIM_VERMITTLER
  where vermittler_nummer='UNK'
    and ist_aktuell='J';

  select coalesce(max(organisationseinheit_key),1) into :l_unk_oe_key trimmed
  from DMVERS.DIM_ORGANISATIONSEINHEIT
  where oe_code='UNK';

  select count(*) into :l_rows_raw trimmed
  from DWHCORE.CORE_PAYOUT_TRANSACTION
  where payout_date_key >= &g_min_event_date;
quit;

proc sql;
  create table work.src_fkt_auszahlung_raw as
  select
    fe.provisionsereignis_key,
    coalesce(dv.vermittler_key, &l_unk_vermittler_key) as vermittler_key,
    coalesce(pot.payout_date_key, 19000101) as auszahlungsdatum_key,
    coalescec(dw.waehrung_key, 'UNK') as waehrung_key length=3,
    coalesce(doe.organisationseinheit_key, &l_unk_oe_key) as organisationseinheit_key,
    substr(pot.source_payout_id,1,64) as auszahlung_id length=64,
    coalesce(pot.payout_amount,0) as ausgezahlt_betrag,
    coalesce(pot.withholding_tax_amount,0) as quellensteuer_betrag,
    coalesce(pot.payment_fee_amount,0) as zahlungsgebuehr_betrag,
    coalesce(
      fx_exact.fx_rate,
      fx_fb.fx_rate,
      case when pot.currency_key = "&g_reporting_ccy" then 1 else . end
    ) as fx_kurs
  from DWHCORE.CORE_PAYOUT_TRANSACTION pot
  left join DWHCORE.CORE_PROVISION_TRANSACTION pt
    on pt.provision_txn_key = pot.provision_txn_key
  left join DWHCORE.CORE_PREMIUM_TRANSACTION pmt
    on pmt.premium_txn_key = pt.premium_txn_key
  left join DWHCORE.CORE_DATE d_pay
    on d_pay.date_key = pot.payout_date_key
  left join DWHCORE.CORE_PARTY_ROLE pr
    on pr.party_role_key = pot.agent_party_role_key
  left join DWHCORE.CORE_PARTY pa
    on pa.party_key = pr.party_key
  left join DWHCORE.CORE_ORG_UNIT cou
    on cou.org_unit_key = pot.org_unit_key
  left join DMVERS.DIM_VERMITTLER dv
    on dv.vermittler_nummer = coalescec(strip(pr.role_identifier), cats('SRC-',strip(pa.source_party_id)))
   and d_pay.calendar_date between dv.gueltig_von and dv.gueltig_bis
  left join DMVERS.DIM_ORGANISATIONSEINHEIT doe
    on doe.oe_code = cou.org_unit_code
  left join DMVERS.DIM_WAEHRUNG dw
    on dw.waehrung_key = pot.currency_key
  left join DWHCORE.CORE_FX_RATE fx_exact
    on fx_exact.from_currency_key = pot.currency_key
   and fx_exact.to_currency_key = "&g_reporting_ccy"
   and fx_exact.rate_date_key = pot.payout_date_key
  left join DWHCORE.CORE_FX_RATE fx_fb
    on fx_fb.from_currency_key = pot.currency_key
   and fx_fb.to_currency_key = "&g_reporting_ccy"
   and fx_fb.rate_date_key = (
      select max(fx2.rate_date_key)
      from DWHCORE.CORE_FX_RATE fx2
      join DWHCORE.CORE_DATE d2
        on d2.date_key = fx2.rate_date_key
      where fx2.from_currency_key = pot.currency_key
        and fx2.to_currency_key = "&g_reporting_ccy"
        and d2.calendar_date < d_pay.calendar_date
        and d2.calendar_date >= (d_pay.calendar_date - 5)
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
  where pot.payout_date_key >= &g_min_event_date;
quit;

data work.src_fkt_auszahlung;
  set work.src_fkt_auszahlung_raw;
  if missing(provisionsereignis_key) then delete;
  if missing(fx_kurs) and waehrung_key ne "&g_reporting_ccy" then delete;
  ausgezahlt_report_ccy = round(ausgezahlt_betrag * fx_kurs, 0.01);
run;

proc sql noprint;
  select count(*) into :l_rows_src trimmed from work.src_fkt_auszahlung;
quit;

%let l_rows_rejected=%eval(&l_rows_raw - &l_rows_src);

%m_fact_upsert(
  src_ds=work.src_fkt_auszahlung,
  tgt_ds=DMVERS.FKT_PROVISIONSAUSZAHLUNG,
  natural_key_cols=auszahlung_id provisionsereignis_key
);

%m_log_run(
  step_name=&l_step_name,
  status=SUCCEEDED,
  rows_read=&l_rows_raw,
  rows_written=&g_last_rows_written,
  rows_rejected=&l_rows_rejected
);
