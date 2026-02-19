"use client";
import { PhaseConfig, phases } from "@/lib/phase-config";
import { Badge } from "@/components/ui/badge";
import { Card } from "@/components/ui/card";
import { Accordion } from "@/components/ui/accordion";
import { MermaidRenderer } from "@/components/mermaid-renderer";
import { useDemoMode } from "@/components/demo-mode-context";
import Link from "next/link";
import { Table, TBody, TD, TH, THead, TR } from "@/components/ui/table";
import { useState } from "react";

function Artifact({ phase }: { phase: PhaseConfig }) {
  const [selected, setSelected] = useState("SAS Job");
  if (phase.artifactType === "mermaid") return <div className="min-h-[520px]"><MermaidRenderer code={phase.mermaidCode!} /></div>;
  if (phase.key === "overview") return <OverviewTimeline />;
  if (phase.key === "phase-0") return <Phase0Artifact />;
  if (phase.key === "phase-1") return <Phase1Artifact selected={selected} setSelected={setSelected} />;
  if (phase.key === "phase-3") return <Phase3Artifact />;
  if (phase.key === "phase-4") return <Phase4Artifact />;
  if (phase.key === "phase-5") return <Phase5Artifact />;
  if (phase.key === "phase-6") return <Phase6Artifact />;
  if (phase.key === "phase-7") return <div className="space-y-4"><div className="flex justify-end"><Badge className="border-accent text-accent">SUCCEEDED</Badge></div><div className="min-h-[480px]"><MermaidRenderer code={phase.mermaidCode!} /></div><div className="flex gap-2">{["KPI-Regression Pack","Reconciliation Report","Validierungsdokumentation"].map((b)=><Badge key={b}>{b}</Badge>)}</div></div>;
  if (phase.key === "transition") return <TransitionArtifact />;
  return null;
}

export function PhasePage({ phase }: { phase: PhaseConfig }) {
  const { demoMode } = useDemoMode();
  return (
    <div className="mx-auto grid max-w-[1200px] gap-6">
      <section>
        <h1 className="text-[32px] font-semibold">{phase.title}</h1>
        <p className="mt-2 text-base text-muted">{phase.objective}</p>
        <div className="mt-4 flex flex-wrap gap-2">{phase.chips.map((chip) => <Badge key={chip} className="border-accent/30 text-accent">{chip}</Badge>)}</div>
      </section>
      <section className="grid gap-4 md:grid-cols-12">
        <Card className={`md:col-span-${demoMode ? "12" : "8"} p-4`}>
          <p className="section-title mb-3">Demo Artifact</p>
          <Artifact phase={phase} />
          {phase.key === "phase-2" && <div className="mt-4 flex items-center gap-2"><Badge className="border-danger text-danger">Zentrale Macros</Badge><Badge className="border-danger text-danger">Stark vernetzte Tabellen</Badge><Badge className="border-danger text-danger">Implizite Scheduler-Ketten</Badge><span className="text-sm text-muted">Hotspots basieren auf Abhängigkeitsgrad + Änderungsfrequenz.</span></div>}
        </Card>
        {!demoMode && <div className="space-y-4 md:col-span-4">
          <Card className="p-4"><p className="section-title mb-2">Deliverables Snapshot</p><ul className="list-disc space-y-1 pl-4 text-sm text-muted">{phase.deliverables.map((d) => <li key={d}>{d}</li>)}</ul></Card>
          <Card className="p-4"><p className="section-title mb-2">Inputs & Aktivitäten</p><div className="mb-3 flex flex-wrap gap-1">{phase.inputs.map((i) => <Badge key={i} className="text-[10px] text-muted">{i}</Badge>)}</div><Accordion items={[{ title: "Aktivitäten", content: phase.activities }]} /></Card>
        </div>}
      </section>
      {demoMode && <Card className="p-4"><p className="section-title mb-2">Deliverables</p><ul className="list-disc space-y-1 pl-4 text-sm text-muted">{phase.deliverables.map((d) => <li key={d}>{d}</li>)}</ul></Card>}
    </div>
  );
}

function OverviewTimeline() {return <div className="space-y-6 overflow-x-auto"><div className="flex min-w-[1360px] items-center gap-2">{phases.filter((p)=>p.key!=="overview").map((p,idx)=><div key={p.route} className="flex items-center gap-2"><Link href={p.route} className={`flex h-12 w-[140px] items-center justify-center rounded-full border text-xs ${idx<2?"border-accent text-accent":"border-border text-muted"}`}>{p.phaseBadge}: {p.navTitle.split("–")[0]}</Link>{idx<8&&<div className="h-[2px] w-8 bg-border" />}</div>)}</div><div className="space-y-2 text-xs text-muted"><p>0 AI Setup läuft parallel</p><p>Reconstruction: Steps 1–3</p><p>Überführung in SOLL: Steps 4–7</p></div></div>}
function Phase0Artifact(){const layers=["Regulatorik","Policies","Security Controls","Runtime"];return <div className="space-y-3"> <div className="flex justify-end"><Badge className="border-accent text-accent">Customer Approved</Badge></div>{layers.map((l)=><div key={l} className="rounded-lg border border-border p-3"><p className="font-medium">{l}</p><ul className="mt-1 list-disc pl-4 text-xs text-muted"><li>DSGVO / EU AI Act</li><li>No Training / No Retention</li><li>VNet/VPC, Private Endpoints, RBAC</li></ul></div>)}<div className="rounded-lg border border-border p-3 text-sm">✅ AI Inventory registriert · ✅ Risk Assessment dokumentiert · ✅ Zugriffsprozesse definiert</div></div>}
function Phase1Artifact({selected,setSelected}:{selected:string;setSelected:(s:string)=>void}){const rows=["SAS Job","Macro","SQL View","Table","Report","Scheduler","Docs"]; return <div className="space-y-4"><div className="grid grid-cols-2 gap-2 lg:grid-cols-4">{["Artefakte gesamt 1'284","SAS Jobs/Macros 612","DB2 Objects 540","Reports 132"].map(t=><div key={t} className="rounded-lg border border-border p-3 text-sm">{t}</div>)}</div><div className="grid gap-3 lg:grid-cols-12"><div className="lg:col-span-8"><Table><THead><TR><TH>Typ</TH><TH>CDWH</TH><TH>Core</TH><TH>DM</TH><TH>BI</TH></TR></THead><TBody>{rows.map(r=><TR key={r}><TD><button className="underline" onClick={()=>setSelected(r)}>{r}</button></TD><TD>12</TD><TD>28</TD><TD>9</TD><TD>6</TD></TR>)}</TBody></Table></div><div className="lg:col-span-4 rounded-lg border border-border p-3 text-xs"><p className="mb-2 font-medium">Filtered: {selected}</p><ul className="space-y-1 text-muted"><li>run_dm_sales_provisioning</li><li>m_fx_fallback</li><li>v_dm_provision</li><li>t_policy</li></ul></div></div><div className="rounded-lg border border-border p-3 text-sm">Selected Scope: 1 Data Mart · 1–2 Jobketten · KPI Satz: 8 KPIs<br/>Top Dependencies: zentrale Macros, FX Tabellen, Scheduler Chain, KPI Views, Report Joins</div></div>}
function Phase3Artifact(){return <div className="grid gap-3 lg:grid-cols-3"><Card className="p-3"><p className="text-sm font-medium">Evidence Sources</p><ul className="mt-2 space-y-2 text-xs text-muted"><li>SAS Macro (92)</li><li>SQL View (88)</li><li>Report (86)</li><li>Wiki (71)</li></ul></Card><Card className="p-3"><p className="text-sm font-medium">Extracted KPI Spec</p><p className="mt-2 text-xs">Netto Provision (Report CCY)</p><pre className="mt-2 overflow-auto rounded bg-[#0b1020] p-2 text-xs">netto_provision_report_ccy = round(netto_provision_betrag * fx_kurs, 0.01)</pre><ul className="mt-2 list-disc pl-4 text-xs text-muted"><li>fx_kurs fallback D-1</li><li>fx_kurs fallback Monatsmittel</li><li>fx_kurs fallback 1.00</li></ul></Card><Card className="p-3"><p className="text-sm font-medium">Call Chain Graph</p><p className="mt-4 text-xs text-muted">run_dm_sales_provisioning → FKT_VERTRIEBSPROVISIONSEREIGNIS → Netto Provision → Sales Provision Dashboard</p></Card></div>}
function Phase4Artifact(){return <div className="space-y-3"><div className="flex justify-end"><Badge className="border-warning text-warning">Show Refactoring Candidates</Badge></div><div className="grid gap-2 lg:grid-cols-2"><div className="rounded-lg border border-border p-3 text-sm">IST Lanes: SAS Jobs & Macros · DB2 Views/Tables · Reports/KPIs</div><div className="rounded-lg border border-border p-3 text-sm">TARGET Lanes: Bronze/Raw · Silver · Gold/Core · Data Marts</div></div><div className="rounded-lg border border-border p-3"><Table><THead><TR><TH>KPI/Datensatz</TH><TH>IST Artefakt</TH><TH>Target Layer</TH><TH>Pattern</TH><TH>Notes</TH></TR></THead><TBody>{Array.from({length:8}).map((_,i)=><TR key={i}><TD>KPI {i+1}</TD><TD>SAS_JOB_{i+1}</TD><TD>Gold/Core</TD><TD>Refactor Pattern A</TD><TD>-30% complexity</TD></TR>)}</TBody></Table></div></div>}
function Phase5Artifact(){return <div className="space-y-4"><div className="flex justify-end"><Badge className="border-accent text-accent">Tolerance ±1.00</Badge></div><Table><THead><TR><TH>KPI</TH><TH>Alt</TH><TH>Neu</TH><TH>Δ absolut</TH><TH>Δ %</TH><TH>Status</TH></TR></THead><TBody>{[["Netto Provision",100,100.2,"0.2","0.2%","PASS"],["Payout",90,89.1,"-0.9","-1.0%","PASS"],["Adjustment",14,12.8,"-1.2","-8.5%","FAIL"],["UNK Rate",0.4,0.45,"0.05","12.5%","PASS"],["FX Drift",2.1,1.9,"-0.2","-9.5%","PASS"],["Contract Count",1800,1797,"-3","-0.17%","PASS"]].map((r)=><TR key={r[0]}><TD>{r[0]}</TD><TD>{r[1]}</TD><TD>{r[2]}</TD><TD>{r[3]}</TD><TD>{r[4]}</TD><TD><Badge className={r[5]==="PASS"?"border-accent text-accent":"border-danger text-danger"}>{r[5]}</Badge></TD></TR>)}</TBody></Table><div className="rounded-lg border border-border p-3 text-sm text-muted">• Abweichung erklärt: FX Fallback Window<br/>• UNK Dimension Rate akzeptiert &lt; 0.5%<br/>• Golden Dataset Snapshot #1 erstellt</div></div>}
function Phase6Artifact(){return <div className="grid gap-3 lg:grid-cols-[1fr_auto_1fr]"><Card className="p-3"><p className="text-sm font-medium">Before</p><p className="mt-2 text-xs text-muted">SAS Macro → SAS Job → DB2 View → … → Report</p><div className="mt-2 flex flex-wrap gap-1"><Badge className="border-warning text-warning">Tight Coupling</Badge><Badge className="border-warning text-warning">Hidden Business Logic</Badge><Badge className="border-warning text-warning">Weak Observability</Badge></div></Card><div className="flex items-center text-sm text-muted">Refactoring Patterns applied →</div><Card className="p-3"><p className="text-sm font-medium">After</p><p className="mt-2 text-xs text-muted">Ingest/Bronze → Silver → Core Model → Data Mart → Tests → Dashboard</p><div className="mt-2 flex flex-wrap gap-1"><Badge className="border-accent text-accent">Idempotent</Badge><Badge className="border-accent text-accent">Restartable</Badge><Badge className="border-accent text-accent">Logged</Badge></div><div className="mt-2 rounded border border-border p-2 text-xs">Data Contract: Schema · Owner · SLA</div><div className="mt-2 flex flex-wrap gap-1 text-xs">{["Standardize naming","Decouple mart logic","Incremental merge","SCD governance"].map(p=><Badge key={p}>{p}</Badge>)}</div></Card></div>}
function TransitionArtifact(){return <div className="space-y-3"><div className="rounded-lg border border-border p-3 text-sm">KW10–23 Gantt: Kick-off & Scope (KW10), AI-Speedboat Setup (KW10–12), AI-gestützte Analyse (KW12–18), Validierung & Review (KW18–21), Demo & Entscheidung (KW21–23)</div><div className="grid gap-2 md:grid-cols-3">{[["Kunde SMEs","Fachliche Validierung","Entscheidungen"],["Speedboat Team","Analyse & Umsetzung","Demo-Artefakte"],["Plattform Team","Betrieb & Security","Cutover Support"]].map((c)=><div key={c[0]} className="rounded-lg border border-border p-3 text-xs"><p className="font-medium text-sm">{c[0]}</p><p className="text-muted">{c[1]}</p><p className="text-muted">{c[2]}</p></div>)}</div></div>}
