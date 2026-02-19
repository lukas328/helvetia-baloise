%put NOTE: [RECON] Running core-vs-dm reconciliation metrics.;

%m_recon_metric(
  metric_name=RECON_ACCRUAL_NET_LOCAL,
  recon_scope=ACCRUAL,
  recon_grain=WINDOW_&g_reprocess_days._DAYS,
  tolerance=1.00,
  source_sql=%str(
    select coalesce(sum(net_provision_amount),0) as metric_value
    from DWHCORE.CORE_PROVISION_TRANSACTION
    where event_effective_date_key >= &g_min_event_date
  ),
  target_sql=%str(
    select coalesce(sum(netto_provision_betrag),0) as metric_value
    from DMVERS.FKT_VERTRIEBSPROVISIONSEREIGNIS
    where abgrenzungsdatum_key >= &g_min_event_date
  ),
  fail_severity=ERROR
);

%m_recon_metric(
  metric_name=RECON_PAYOUT_LOCAL,
  recon_scope=PAYOUT,
  recon_grain=WINDOW_&g_reprocess_days._DAYS,
  tolerance=1.00,
  source_sql=%str(
    select coalesce(sum(payout_amount),0) as metric_value
    from DWHCORE.CORE_PAYOUT_TRANSACTION
    where payout_date_key >= &g_min_event_date
  ),
  target_sql=%str(
    select coalesce(sum(ausgezahlt_betrag),0) as metric_value
    from DMVERS.FKT_PROVISIONSAUSZAHLUNG
    where auszahlungsdatum_key >= &g_min_event_date
  ),
  fail_severity=ERROR
);

%m_recon_metric(
  metric_name=RECON_ADJUSTMENT_LOCAL,
  recon_scope=ADJUSTMENT,
  recon_grain=WINDOW_&g_reprocess_days._DAYS,
  tolerance=1.00,
  source_sql=%str(
    select coalesce(sum(adjustment_amount),0) as metric_value
    from DWHCORE.CORE_ADJUSTMENT_TRANSACTION
    where adjustment_date_key >= &g_min_event_date
  ),
  target_sql=%str(
    select coalesce(sum(anpassung_betrag),0) as metric_value
    from DMVERS.FKT_PROVISIONSANPASSUNG
    where anpassungsdatum_key >= &g_min_event_date
  ),
  fail_severity=ERROR
);

%m_log_run(step_name=RECON_CORE_DM, status=SUCCEEDED, rows_read=0, rows_written=0, rows_rejected=0);
