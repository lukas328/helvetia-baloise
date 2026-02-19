export type RouteKey = "overview" | "phase-0" | "phase-1" | "phase-2" | "phase-3" | "phase-4" | "phase-5" | "phase-6" | "phase-7" | "transition";
export type ArtifactType = "timeline" | "canvas" | "dashboard" | "mermaid" | "mapping" | "gantt";

export type PhaseConfig = {
  key: RouteKey;
  route: string;
  navTitle: string;
  phaseBadge: string;
  miniStatus: string;
  title: string;
  objective: string;
  chips: string[];
  deliverables: string[];
  inputs: string[];
  activities: string[];
  artifactType: ArtifactType;
  mermaidCode?: string;
};

const mermaid01 = `flowchart LR
  subgraph SRC[Operational Source Systems]
    S1[Policy Admin]
    S2[Commission Engine]
    S3[Partner/Agent Master]
    S4[Reference Data / FX]
  end

  subgraph STG[STG_INS Raw Landing]
    STG1[STG_POLICY]
    STG2[STG_PRODUCT]
    STG3[STG_PARTY]
    STG4[STG_*_EVENT]
  end

  subgraph WRK[WRK_INS Integration]
    WRK1[WRK_POLICY / WRK_PRODUCT / WRK_PARTY]
    WRK2[WRK_*_EVENT]
    WRK3[WRK_REFERENCE]
    WRK4[WRK_REJECT]
  end

  subgraph CORE[DWH_CORE Enterprise Canonical]
    C1[Master + Reference Dimensions]
    C2[Policy/Agent Relationships]
    C3[Premium / Provision / Payout / Adjustment Transactions]
    C4[CORE_FX_RATE]
    C5[CORE_RECORD_LINEAGE]
  end

  subgraph DM[DM_VERSICHERUNG Sales Provisioning Mart]
    D1[Dimensions]
    D2[Bridges]
    D3[Fact Accrual]
    D4[Fact Payout]
    D5[Fact Adjustment]
  end

  subgraph CTL[CTL_INS Control and Quality]
    T1[CTL_BATCH_RUN]
    T2[CTL_BATCH_STEP]
    T3[CTL_DQ_RESULT]
    T4[CTL_RECON_RESULT]
    T5[CTL_WATERMARK]
    T6[CTL_ALERT]
  end

  SRC --> STG --> WRK --> CORE --> DM
  WRK --> WRK4
  CORE --> C5

  ETL[SAS Batch Orchestrator]
  ETL --> DM
  ETL --> CTL`;

const mermaid06 = `flowchart TD
  A[Batch Trigger] --> B[CTL_BATCH_RUN insert RUNNING]
  B --> C[Mapping Steps 01..13]
  C --> D[CTL_BATCH_STEP logs]

  C --> E[DQ Assertions]
  E --> F[CTL_DQ_RESULT inserts]

  F --> G[Reconciliation Metrics]
  G --> H[CTL_RECON_RESULT inserts]

  H --> I{g_has_error > 0?}
  I -- No --> J[Set run status SUCCEEDED]
  I -- Yes --> K[Set run status FAILED]

  J --> L[Update CTL_BATCH_RUN end_ts + status]
  K --> L

  L --> M{Status SUCCEEDED?}
  M -- Yes --> N[Upsert CTL_WATERMARK for CORE transaction entities]
  M -- No --> O[Abort batch]

  N --> P[Log RUN_END in CTL_BATCH_STEP]
  O --> P

  Q[CTL_ALERT table exists] -. currently not populated .-> P`;

export const phases: PhaseConfig[] = [
  { key:"overview", route:"/", navTitle:"Overview", phaseBadge:"OV", miniStatus:"Deliverable", title:"WHAT – Unser bewährtes Vorgehen für Legacy Transformationen mit AI", objective:"Von IST-Reconstruction bis Validierung und Skalierung", chips:["IST-Transparenz","Fachlich validiert","Zielarchitektur-konform"], deliverables:["End-to-End Vorgehensmodell über 0–7 + Transition Plan","Klare Artefakte je Phase mit Demo-Fokus","Abgestimmte Entscheidungsgrundlage für Refactoring","Nachweis fachlicher Gleichwertigkeit Alt vs Neu","Roadmap für Regelbetrieb und Skalierung","Governance, Qualität und Betriebsfähigkeit"], inputs:["RFI Scope und Prioritäten","Legacy-Artefakte und Dokumentation","Zielarchitektur und Governance-Rahmen"], activities:["Phasenmodell abstimmen","Schlüsselartefakte pro Phase definieren","Demo-Storyline und Entscheidungspunkte strukturieren"], artifactType:"timeline" },
  { key:"phase-0", route:"/phase-0", navTitle:"Phase 0 – AI-Setup", phaseBadge:"0", miniStatus:"Input", title:"Phase 0: AI-Setup – Schaffung des benötigten Fundaments", objective:"Frühzeitige Eliminierung von Compliance-Risiken und Aufbau einer wiederverwendbaren AI-Governance.", chips:["Governance & Compliance","Isolierte Runtime","Freigabe durch Kunde"], deliverables:["Freigegebene AI Landingpage","Dokumentiertes Governance & Compliance Set","Definierte Betriebs- und Zugriffsprozesse (RBAC, Secrets)","Lauffähige AI Agent Umgebung","Freigabe der Umgebung durch den Kunden"], inputs:["DSGVO","EU AI Act","interne Richtlinien","Data Governance","Architektur-Standards","AI Inventory"], activities:["Isolierte AI Agent Runtime (VNet/VPC, private Endpoints)","IaC Terraform","No Training/No Retention + Logging Policy","Abuse Monitoring / Prompt Shield","Use Case Registrierung im AI Inventory inkl. Controls","Datenklassifikation PoC","Technische Tests mit Agents"], artifactType:"canvas" },
  { key:"phase-1", route:"/phase-1", navTitle:"Phase 1 – Data Gathering & Scope", phaseBadge:"1", miniStatus:"Input", title:"Phase 1: Data Gathering, Classification & Scope", objective:"Vollständige IST-Transparenz und ein klar abgegrenzter PoC-Scope, der bewertbar und demofähig ist.", chips:["Artefakt-Inventar","Klassifikation","PoC Erfolgskriterien"], deliverables:["Vollständiges Artefakt-Inventar inkl. Klassifikation","Dokumentierte Domänen- und Schichtzuordnung der Artefakte","PoC Scope Dokument inkl. Erfolgskriterien und benötigten Zugriffsrechten"], inputs:["Scope/Prioritäten Vertrieb","KPI-Referenzen","SAS EG/DI Artefakte","SQL/DB2 DDL/Views","Cobol/Shell/Python","Scheduler/Cron","Job Logs","Reports","Dokus (PDF/Confluence/Miro)"], activities:["Artefakte sammeln/extrahieren","AI-gestütztes Inventar aufbauen","Klassifikation nach Schichten/Domänen","Implizite Logik identifizieren (Shell Chains, Cron, Macros)","PoC Scope eingrenzen","Erfolgskriterien definieren"], artifactType:"dashboard" },
  { key:"phase-2", route:"/phase-2", navTitle:"Phase 2 – Architecture Reconstruction (IST)", phaseBadge:"2", miniStatus:"Processing", title:"Phase 2: Architecture Reconstruction (IST)", objective:"Technische und fachliche Architektur rekonstruieren, sodass sie für Stakeholder verständlich und prüfbar ist.", chips:["Lineage Graph","Job Chains","Komplexitäts-Hotspots"], deliverables:["Dokumentierte Pfade und Abhängigkeiten","Lineage-Graphen und Architekturdiagramme","Übersicht Schichten/Datenprodukte inkl. Verantwortlichkeiten","Risiko-/Komplexitäts-Hotspots"], inputs:["Artefakt-Inventar","DB2 Metadaten","Views/Constraints","Zugriffsmuster/Query-Stats","SAS DI Flow Definitionen","Scheduler Infos","Schnittstellen-Konfigurationen","technische Dokumentation"], activities:["Read/Write Analyse über Code/SQL","Job-/Pipeline-Abhängigkeitsgraphen (inkl. implizite Ketten)","Schnittstellen identifizieren","Business View & Tech View ableiten","Validierung mit SMEs"], artifactType:"mermaid", mermaidCode: mermaid01 },
  { key:"phase-3", route:"/phase-3", navTitle:"Phase 3 – Business Logic & KPI Extraction", phaseBadge:"3", miniStatus:"Processing", title:"Phase 3: Business Logic & KPI Extraction", objective:"KPI-Definitionen und Business-Regeln aus Code/Reports extrahieren und replizierbar dokumentieren.", chips:["KPI Specs","Regelkatalog","Call Chains"], deliverables:["KPI-Spezifikationen (menschenlesbar + technisch referenzierbar)","Dokumentierte Business-Regeln inkl. Quellenverweis","Call-Chain-Graphen und Regelkatalog inkl. offener Punkte"], inputs:["SAS Code/Macros","SQL/Jobs","Data Mart Definitionen","Report Definitionen","Glossare/Wiki","Ergebnisse Phase 2","Tabellen- & Datenmodellbeschreibungen"], activities:["KPI-Definitionen extrahieren","Business Regeln identifizieren (SCD-Logik, Historisierung)","Call Chains aufbauen","Validierung mit SMEs"], artifactType:"canvas" },
  { key:"phase-4", route:"/phase-4", navTitle:"Phase 4 – Mapping IST → Target (DARTS)", phaseBadge:"4", miniStatus:"Processing", title:"Phase 4: Mapping IST → DARTS Target Architecture", objective:"IST-Logik auf SOLL-Schichten abbilden – zielarchitekturkonform, ohne strukturelle Änderungen.", chips:["Mapping Matrix","Target Flows","Refactoring Kandidaten"], deliverables:["Mapping-Matrix IST → SOLL (pro KPI, Datensatz, Job)","Zielbild Data Flows (schichtenkonform)","AI-Agent Mapping-Spezifikationen","Liste Refactoring-Kandidaten inkl. erwarteter Wirkung"], inputs:["Ergebnisse Phase 2/3","Zielarchitektur-Vorgaben","Ziel-Datenmodelle","KPI-Verantwortlichkeiten","Governance/Namenskonventionen","Scope Definition"], activities:["Mapping IST Logik auf Zielschichten","Redundanzen/Vereinfachungspotenzial","Harmonisierung KPIs/Konsolidierung Data Marts","Mapping Spezifikationen definieren","Refactoring Patterns ableiten"], artifactType:"mapping" },
  { key:"phase-5", route:"/phase-5", navTitle:"Phase 5 – Baseline Validation", phaseBadge:"5", miniStatus:"Deliverable", title:"Phase 5: Baseline Validation (pre-refactoring)", objective:"Fachlich abgenommene Baseline als Referenz, bevor strukturelle Änderungen stattfinden.", chips:["Golden Datasets","Alt vs Neu","Decision Log"], deliverables:["Verifizierte fachliche Baseline","Dokumentierter Abweichungs- und Entscheidungslog","Golden Dataset Definitionen"], inputs:["Ergebnisse Phase 3/4","Migration Spezifikationen","DAWIS Reports","Stichproben Quellsysteme","Lineage/Architektur Artefakte","Validierungsregeln"], activities:["AI-Agent generiert Zielcode-Prototypen (PySpark/SQL)","Vergleich KPI Ergebnisse Alt vs Neu","Testläufe Alt vs Neu","SME Validierung","Golden Datasets definieren/aufbauen"], artifactType:"dashboard" },
  { key:"phase-6", route:"/phase-6", navTitle:"Phase 6 – Refactoring & Improvement", phaseBadge:"6", miniStatus:"Processing", title:"Phase 6: Refactoring & Improvement", objective:"Strukturelle, fachliche und technische Verbesserungen auf Basis verifizierter Logik umsetzen.", chips:["Patterns","Data Contracts","Observability"], deliverables:["Refactored Pipelines und Data Marts","Technische Design-Dokumente und Data Contracts","Dokumentierte Architektur- und Implementierungsentscheidungen"], inputs:["Ergebnisse Phase 4/5","Refactoring Kandidaten","Standards","KPI Spezifikationen","Qualitätsanforderungen"], activities:["Patterns umsetzen","Pipelines/Data Marts neu zuschneiden","Idempotenz/Wiederanlaufbarkeit/Observability","KPI Harmonisierung","Data Contracts & Design Artefakte"], artifactType:"canvas" },
  { key:"phase-7", route:"/phase-7", navTitle:"Phase 7 – Validation (Alt vs Refactored)", phaseBadge:"7", miniStatus:"Deliverable", title:"Phase 7: Validation (Alt vs Refactored)", objective:"Nachweis der fachlichen Gleichwertigkeit oder Verbesserung der refactorten Lösung.", chips:["Parallel Operations","Regression Pack","Evidence Logs"], deliverables:["KPI-Regression Pack","Reconciliation Reports","Evidence Logs und Validierungsdokumentation"], inputs:["Stabiler Daten Cutoff","Toleranzen","Refactored Pipelines","Alt Pipelines/Reports","Golden Datasets","KPI Regeln","Data Catalog Metadaten","Orchestrierung (Airflow)"], activities:["Parallelbetrieb Alt vs Neu","Feld-für-Feld Vergleich + KPI Regression","Report Vergleich","Anbindung Datenkatalog/Orchestrierung","Dokumentation Abweichungen"], artifactType:"mermaid", mermaidCode: mermaid06 },
  { key:"transition", route:"/transition", navTitle:"Transition Plan & Collaboration Model", phaseBadge:"TP", miniStatus:"Deliverable", title:"Transition Plan & Collaboration Model", objective:"Kontrollierte, risikoarme Überführung in den Regelbetrieb und Skalierung auf weitere Use Cases.", chips:["Wellenmodell","Cutover","Hypercare"], deliverables:["End-to-End Migrations-Roadmap","Definiertes Team- und Rollenmodell","Cutover- und Hypercare-Plan","Skalierungsstrategie für weitere Migrationen"], inputs:["Roadmap Vorgaben","Betriebsanforderungen","Rollen und Kapazitäten"], activities:["Wellenmodell definieren","Abschaltplan Legacy","Zusammenarbeitsmodell (Embedded/Speedboat/Mixed)","Cutover/Hypercare/Stabilisierung","Skalierungsplanung"], artifactType:"gantt" }
];

export const phaseByRoute = Object.fromEntries(phases.map((p) => [p.route, p]));
