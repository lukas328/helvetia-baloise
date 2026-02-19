"use client";

import mermaid from "mermaid";
import { useEffect, useState } from "react";

export function MermaidRenderer({ code }: { code: string }) {
  const [svg, setSvg] = useState("");
  useEffect(() => {
    mermaid.initialize({ startOnLoad: false, theme: "dark", securityLevel: "loose" });
    mermaid.render(`m-${Math.random().toString(36).slice(2)}`, code).then(({ svg }) => setSvg(svg));
  }, [code]);

  return <div className="overflow-auto [&_svg]:h-auto [&_svg]:w-full" dangerouslySetInnerHTML={{ __html: svg }} />;
}
