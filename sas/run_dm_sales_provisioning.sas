/* Orchestrator: DWH_CORE -> DM_VERSICHERUNG sales provisioning */
%let g_sas_home=/home/dirk/workspace/helvetia/sas;

%include "&g_sas_home/config/00_options.sas";
%include "&g_sas_home/config/20_runtime_parameters.sas";
%include "&g_sas_home/config/10_libnames_db2.sas";

%include "&g_sas_home/macros/m_log_run.sas";
%include "&g_sas_home/macros/m_scd2_merge.sas";
%include "&g_sas_home/macros/m_fact_upsert.sas";
%include "&g_sas_home/macros/m_lookup_key.sas";
%include "&g_sas_home/macros/m_dq_assert.sas";
%include "&g_sas_home/macros/m_recon_metric.sas";

%include "&g_sas_home/ctl/01_start_run.sas";

%include "&g_sas_home/mapping/01_dim_datum.sas";
%include "&g_sas_home/mapping/02_dim_waehrung.sas";
%include "&g_sas_home/mapping/03_dim_organisation_kanal_grund.sas";
%include "&g_sas_home/mapping/04_dim_police.sas";
%include "&g_sas_home/mapping/05_dim_produkt.sas";
%include "&g_sas_home/mapping/06_dim_vermittler.sas";
%include "&g_sas_home/mapping/07_dim_provisionsplan.sas";
%include "&g_sas_home/mapping/08_dim_provisionsregel.sas";
%include "&g_sas_home/mapping/09_bridge_police_vermittler.sas";
%include "&g_sas_home/mapping/10_bridge_vermittler_hierarchie.sas";
%include "&g_sas_home/mapping/11_fact_vertriebsprovisionsereignis.sas";
%include "&g_sas_home/mapping/12_fact_provisionsauszahlung.sas";
%include "&g_sas_home/mapping/13_fact_provisionsanpassung.sas";

%include "&g_sas_home/quality/01_dq_core_to_dm.sas";
%include "&g_sas_home/quality/02_reconciliation_core_vs_dm.sas";

%include "&g_sas_home/ctl/02_end_run.sas";
