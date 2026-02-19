import React, { useEffect, useState } from 'react';
import { createRoot } from 'react-dom/client';
import htm from 'https://esm.sh/htm@3';
import mermaid from 'https://esm.sh/mermaid@11';
import { ShieldCheck, CheckCircle, PanelRightOpen, PanelRightClose } from 'lucide-react';
import { Prism as SyntaxHighlighter } from 'react-syntax-highlighter';
import { oneLight } from 'react-syntax-highlighter/dist/esm/styles/prism';
import { PieChart, Pie, Cell, ResponsiveContainer } from 'recharts';

const html = htm.bind(React.createElement);
mermaid.initialize({ startOnLoad: false, theme: 'default', securityLevel: 'loose' });

const phases = [
  'Phase 0: Setup',
  'Phase 1: Data Gathering',
  'Phase 2: Architecture',
  'Phase 3: Business Logic',
  'Phase 4: Mapping',
  'Phase 5: Validation Lab',
  'Phase 6: Refactoring',
  'Phase 7: Handover'
];

const architectureMmd = `flowchart LR
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

const controlFlow = `flowchart TD
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
  K --> L`;

function Mermaid({ chart }) {
  const [svg, setSvg] = useState('');
  useEffect(() => {
    let mounted = true;
    mermaid.render(`m-${Math.random()}`, chart).then(({ svg }) => mounted && setSvg(svg));
    return () => {
      mounted = false;
    };
  }, [chart]);
  return html`<div className="bg-white rounded-xl p-4 border overflow-auto" dangerouslySetInnerHTML=${{ __html: svg }} />`;
}

function TreeNode({ name, children, defaultOpen = false }) {
  const [open, setOpen] = useState(defaultOpen);
  return html`<div className="ml-2">
    <button onClick=${() => setOpen(!open)} className="text-sm">${children ? '📁' : '📄'} ${name}</button>
    ${open && children ? html`<div className="ml-4 mt-1">${children}</div>` : null}
  </div>`;
}

function Phase0() {
  return html`<div className="grid grid-cols-3 gap-4">
    <div className="bg-white border rounded-xl p-5">
      <${ShieldCheck} className="text-emerald-600" />
      <h3 className="font-semibold mt-3">Infrastructure</h3>
      <p className="text-sm mt-1">Azure Landing Zone: Helvetia-DARTS</p>
      <div className="mt-4 flex items-center gap-2"><span className="w-3 h-3 bg-green-500 rounded-full pulse-dot"></span>Active</div>
    </div>
    <div className="bg-white border rounded-xl p-5">
      <h3 className="font-semibold mb-3">Compliance Code</h3>
      <pre className="bg-slate-900 text-slate-100 p-4 rounded text-sm"><code>ai_services: azure_openai
endpoint: private_link
data_logging: false
<mark className="bg-yellow-300 text-slate-900">opt_out_training: true</mark></code></pre>
    </div>
    <div className="bg-white border rounded-xl p-5">
      <${CheckCircle} className="text-emerald-600" />
      <h3 className="font-semibold mt-3">Certification</h3>
      <p className="mt-2">EU AI Act Compliant & No Data Retention</p>
    </div>
  </div>`;
}

function Phase1() {
  const kpis = [
    ['STG_INS Tables', 14],
    ['DWH_CORE Tables', 18],
    ['DM_VERSICHERUNG Tables', 15],
    ['Mapping Scripts', 13]
  ];

  return html`<div className="grid grid-cols-2 gap-6">
    <div className="bg-white border rounded-xl p-4">
      <h3 className="font-semibold mb-3">Repository File Tree</h3>
      <${TreeNode} name="ddl/ (5 SQL Files)" defaultOpen=${true}>
        <div>📄 10_stg_layer.sql</div><div>📄 30_dwh_core_layer.sql</div>
      </${TreeNode}>
      <${TreeNode} name="sas/" defaultOpen=${true}>
        <${TreeNode} name="ctl/ (2 Scripts)" defaultOpen=${true}><div>📄 01_start_run.sas</div><div>📄 02_end_run.sas</div></${TreeNode}>
        <${TreeNode} name="macros/ (6 Macros)" defaultOpen=${true}><div>📄 m_scd2_merge.sas</div></${TreeNode}>
        <${TreeNode} name="mapping/ (13 Mapping Steps)" defaultOpen=${true}><div>📄 11_fact_vertriebsprovisionsereignis.sas</div></${TreeNode}>
      </${TreeNode}>
    </div>
    <div className="grid grid-cols-2 gap-4">
      ${kpis.map(([k, v]) => html`<div key=${k} className="bg-white border rounded-xl p-6"><p className="text-sm text-slate-500">${k}</p><p className="text-3xl font-bold mt-2">${v}</p></div>`) }
    </div>
  </div>`;
}

function Phase2() {
  const [hover, setHover] = useState(false);
  return html`<div className="relative" onMouseLeave=${() => setHover(false)}>
    <div className="mb-2 text-sm text-slate-500">Hover CORE area for details.</div>
    <div onMouseEnter=${() => setHover(true)}><${Mermaid} chart=${architectureMmd} /></div>
    ${hover ? html`<div className="absolute top-16 right-8 bg-slate-900 text-white text-xs px-3 py-2 rounded">Enthält: CORE_PARTY, CORE_POLICY, CORE_PREMIUM_TRANSACTION</div>` : null}
  </div>`;
}

function Phase3() {
  const code = `/* 11_fact_vertriebsprovisionsereignis.sas */\nproc sql;\n  create table work.fact_base as\n  select t.source_system_id as quell_system_id,\n         t.source_premium_txn_id as praemientransaktion_id,\n         a.agent_key as vermittler_key,\n         t.gross_commission_amt as brutto_provision_betrag,\n         t.net_commission_amt as netto_provision_betrag\n  from dwh_core.core_provision_transaction t;\nquit;`;
  return html`<div className="grid grid-cols-2 gap-4 h-full">
    <div className="bg-[#1e1e1e] rounded-xl p-3 overflow-auto"><${SyntaxHighlighter} language="sas" style=${oneLight}>${code}</${SyntaxHighlighter}></div>
    <div className="bg-white rounded-xl border p-5">
      <h3 className="font-semibold">Business Rules</h3>
      <ul className="list-disc ml-6 mt-3 space-y-2">
        <li><b>Natural Keys:</b> quell_system_id, praemientransaktion_id, vermittler_key.</li>
        <li><b>Derived Measures:</b> brutto_provision_betrag, netto_provision_betrag.</li>
        <li><b>Filter-Logik:</b> accrual_date_key >= g_min_event_date.</li>
      </ul>
    </div>
  </div>`;
}

function Phase4() {
  const [tab, setTab] = useState('core');
  const [coreER, setCoreER] = useState('erDiagram\nA ||--o{ B : demo');
  const [dmER, setDmER] = useState('erDiagram\nX ||--o{ Y : demo');

  useEffect(() => {
    fetch('/documentation/diagrams/03_core_er_model.mmd').then((r) => r.text()).then(setCoreER);
    fetch('/documentation/diagrams/04_dm_star_and_bridges.mmd').then((r) => r.text()).then(setDmER);
  }, []);

  return html`<div>
    <div className="flex justify-center mb-4">
      <div className="bg-white border rounded-full p-1">
        <button onClick=${() => setTab('core')} className=${`px-4 py-2 rounded-full ${tab === 'core' ? 'bg-cyan-600 text-white' : ''}`}>DWH_CORE Entity Model</button>
        <button onClick=${() => setTab('dm')} className=${`px-4 py-2 rounded-full ${tab === 'dm' ? 'bg-cyan-600 text-white' : ''}`}>DM Target Star Schema</button>
      </div>
    </div>
    <div className="fade-enter">${tab === 'core' ? html`<${Mermaid} chart=${coreER} />` : html`<${Mermaid} chart=${dmER} />`}</div>
  </div>`;
}

function Phase5() {
  const [step, setStep] = useState(-1);
  const labels = ['C (Mapping)', 'E (DQ Assertions)', 'G (Recon Metrics)', 'J (SUCCEEDED)'];
  const run = () => [0, 1, 2, 3].forEach((s, i) => setTimeout(() => setStep(s), 700 * (i + 1)));

  return html`<div>
    <button onClick=${run} className="mb-4 px-4 py-2 bg-emerald-600 text-white rounded">Run Baseline Test</button>
    <${Mermaid} chart=${controlFlow} />
    <div className="mt-4 flex gap-3">${labels.map((l, i) => html`<div key=${l} className=${`px-3 py-2 rounded border ${step === i ? 'bg-green-200 border-green-500' : 'bg-white'}`}>${l}</div>`)}</div>
  </div>`;
}

function Phase6() {
  const txt = `# AI Generated PySpark Logic for Incremental Window\nreprocessing_window_days = 45\ng_min_event_date = current_date() - expr(f"INTERVAL {reprocessing_window_days} DAYS")\n\n# Currency Conversion (CHF)\ndf = df.withColumn("reporting_currency", lit("CHF")) \\\n       .withColumn("exchange_rate", get_fx_rate(col("currency"), lit("CHF"), col("transaction_date")))`;
  const [shown, setShown] = useState('');

  useEffect(() => {
    let i = 0;
    const id = setInterval(() => {
      i += 1;
      setShown(txt.slice(0, i));
      if (i >= txt.length) clearInterval(id);
    }, 15);
    return () => clearInterval(id);
  }, [txt]);

  return html`<div className="space-y-4">
    <div className="bg-black text-green-400 rounded-xl p-4 font-mono text-sm min-h-56 whitespace-pre-wrap typing-cursor">${shown}</div>
    <div className="bg-white border rounded-xl p-6"><h3 className="font-semibold">Databricks Mockup</h3><div className="mt-3 h-44 bg-slate-100 border rounded flex items-center justify-center text-slate-500">Notebook Runtime • Cluster: ai-modernization</div></div>
  </div>`;
}

function Phase7() {
  const data = [{ name: 'pass', value: 100 }, { name: 'rest', value: 0.0001 }];
  return html`<div className="space-y-6">
    <div className="bg-white border rounded-xl p-4">
      <h3 className="font-semibold mb-3">Quality Gate Checklist</h3>
      <div className="grid grid-cols-2 gap-2">${Array.from({ length: 13 }, (_, i) => html`<label key=${i} className="text-sm">✅ Mapping Step ${String(i + 1).padStart(2, '0')} passed</label>`)}</div>
    </div>
    <div className="grid grid-cols-2 gap-4">
      ${['DQ Assertions', 'Reconciliation Matches'].map((t) => html`<div key=${t} className="bg-white border rounded-xl p-4 h-48"><p className="text-sm mb-2">${t} (100% Passed)</p><${ResponsiveContainer} width="100%" height="100%"><${PieChart}><${Pie} data=${data} dataKey="value" innerRadius=${45} outerRadius=${65}><${Cell} fill="#10b981" /><${Cell} fill="#e2e8f0" /></${Pie}></${PieChart}></${ResponsiveContainer}></div>`) }
    </div>
    <button className="w-full py-4 bg-cyan-700 text-white rounded-xl font-semibold">Deploy to Unity Catalog / Promote to Prod</button>
  </div>`;
}

const rightPanel = {
  0: ['Governance Sentinel', 'Governance & Secure Zone aktiv.'],
  1: ['Inventory Harvester', 'Datei-Inventar und Scope extrahiert.'],
  2: ['Lineage Architect', 'Architektur-Layer und End-to-End Flow rekonstruiert.'],
  3: ['Logic Decipher', 'Wandelt technischen SAS-Code in lesbare Business-KPIs um'],
  4: ['Structure Mapper', 'Normalisiertes Modell wird auf Star-Schema gemappt.'],
  5: ['Validation Engine', 'DQ-Checks und Reconciliation-Logik erfolgreich gegen Legacy Data gematcht.'],
  6: ['Code Modernizer', 'Automatische Implementierung von 45-Tage Reprocessing und Fallback FX-Rates'],
  7: ['Final Auditor', 'Wasserzeichen (CTL_WATERMARK) gesetzt. Run Status: SUCCEEDED.']
};

function App() {
  const [phase, setPhase] = useState(0);
  const [rightOpen, setRightOpen] = useState(true);
  const renderPhase = () => {
    if (phase === 0) return html`<${Phase0} />`;
    if (phase === 1) return html`<${Phase1} />`;
    if (phase === 2) return html`<${Phase2} />`;
    if (phase === 3) return html`<${Phase3} />`;
    if (phase === 4) return html`<${Phase4} />`;
    if (phase === 5) return html`<${Phase5} />`;
    if (phase === 6) return html`<${Phase6} />`;
    return html`<${Phase7} />`;
  };

  return html`<div className="h-screen flex">
    <aside className="w-[250px] bg-slate-900 text-slate-100 p-4">
      <h1 className="text-lg font-bold mb-6">mesoneer AI-Accelerator</h1>
      <nav className="space-y-1">${phases.map((p, i) => html`<button key=${p} onClick=${() => setPhase(i)} className=${`w-full text-left px-3 py-2 rounded ${phase === i ? 'bg-cyan-600' : 'hover:bg-slate-800'}`}>${p}</button>`)}</nav>
    </aside>
    <main className="flex-1 bg-slate-50 p-6 overflow-auto">${renderPhase()}</main>
    <section className=${`${rightOpen ? 'w-[300px]' : 'w-12'} transition-all duration-300 bg-white border-l`}>
      <button className="p-3" onClick=${() => setRightOpen(!rightOpen)}>${rightOpen ? html`<${PanelRightClose} size=${18} />` : html`<${PanelRightOpen} size=${18} />`}</button>
      ${rightOpen ? html`<div className="px-4 pb-4"><h3 className="font-semibold">Aktiver AI-Agent</h3><p className="mt-2 text-cyan-700 font-medium">${rightPanel[phase][0]}</p><h4 className="mt-4 font-semibold">Metadaten</h4><p className="text-sm text-slate-600 mt-1">${rightPanel[phase][1]}</p></div>` : null}
    </section>
  </div>`;
}

createRoot(document.getElementById('root')).render(html`<${App} />`);
