%put NOTE: [DQ] Running mandatory core-to-dm data quality assertions.;

%m_dq_assert(
  check_name=DQ_VPE_COMPLETENESS,
  layer_name=DM,
  entity_name=FKT_VERTRIEBSPROVISIONSEREIGNIS,
  severity=ERROR,
  fail_threshold=0,
  sql_expr=%str(
    select
      count(*) as tested_rows,
      coalesce(sum(
        case
          when police_key is null
            or produkt_key is null
            or vermittler_key is null
            or vertriebskanal_key is null
            or provisionsplan_key is null
            or provisionsregel_key is null
            or organisationseinheit_key is null
            or waehrung_key is null
            or abgrenzungsdatum_key is null
            or buchungsdatum_key is null
          then 1 else 0
        end
      ),0) as failed_rows
    from DMVERS.FKT_VERTRIEBSPROVISIONSEREIGNIS
    where abgrenzungsdatum_key >= &g_min_event_date
  )
);

%m_dq_assert(
  check_name=DQ_PAYOUT_FK,
  layer_name=DM,
  entity_name=FKT_PROVISIONSAUSZAHLUNG,
  severity=ERROR,
  fail_threshold=0,
  sql_expr=%str(
    select
      count(*) as tested_rows,
      coalesce(sum(case when provisionsereignis_key is null then 1 else 0 end),0) as failed_rows
    from DMVERS.FKT_PROVISIONSAUSZAHLUNG
    where auszahlungsdatum_key >= &g_min_event_date
  )
);

%m_dq_assert(
  check_name=DQ_ADJUSTMENT_FK,
  layer_name=DM,
  entity_name=FKT_PROVISIONSANPASSUNG,
  severity=ERROR,
  fail_threshold=0,
  sql_expr=%str(
    select
      count(*) as tested_rows,
      coalesce(sum(case when provisionsereignis_key is null then 1 else 0 end),0) as failed_rows
    from DMVERS.FKT_PROVISIONSANPASSUNG
    where anpassungsdatum_key >= &g_min_event_date
  )
);

%m_dq_assert(
  check_name=DQ_BR_SPLIT_100,
  layer_name=DM,
  entity_name=BR_POLICE_VERMITTLER_AUFTEILUNG,
  severity=ERROR,
  fail_threshold=0,
  sql_expr=%str(
    select
      count(*) as tested_rows,
      coalesce(sum(case when abs(split_sum - 100) > 0.01 then 1 else 0 end),0) as failed_rows
    from (
      select
        police_key,
        gueltig_von,
        sum(aufteilungsquote_prozent) as split_sum
      from DMVERS.BR_POLICE_VERMITTLER_AUFTEILUNG
      group by police_key, gueltig_von
    ) x
  )
);

%m_dq_assert(
  check_name=DQ_VPE_DUP_GRAIN,
  layer_name=DM,
  entity_name=FKT_VERTRIEBSPROVISIONSEREIGNIS,
  severity=ERROR,
  fail_threshold=0,
  sql_expr=%str(
    select
      count(*) as tested_rows,
      coalesce(sum(case when dup_cnt > 1 then 1 else 0 end),0) as failed_rows
    from (
      select
        quell_system_id,
        praemientransaktion_id,
        vermittler_key,
        abrechnungsperiode,
        abgrenzungsdatum_key,
        count(*) as dup_cnt
      from DMVERS.FKT_VERTRIEBSPROVISIONSEREIGNIS
      where abgrenzungsdatum_key >= &g_min_event_date
      group by
        quell_system_id,
        praemientransaktion_id,
        vermittler_key,
        abrechnungsperiode,
        abgrenzungsdatum_key
    ) d
  )
);

%m_log_run(step_name=DQ_CORE_TO_DM, status=SUCCEEDED, rows_read=0, rows_written=0, rows_rejected=0);
