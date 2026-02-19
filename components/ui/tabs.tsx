"use client";
import { useState } from "react";
import { cn } from "@/lib/utils";

export function Tabs({ tabs }: { tabs: { label: string; content: React.ReactNode }[] }) {
  const [active, setActive] = useState(0);
  return (
    <div>
      <div className="mb-3 flex gap-2">
        {tabs.map((tab, idx) => (
          <button key={tab.label} className={cn("rounded-full border px-3 py-1 text-xs", idx === active ? "border-accent text-accent" : "border-border text-muted")} onClick={() => setActive(idx)}>
            {tab.label}
          </button>
        ))}
      </div>
      <div>{tabs[active]?.content}</div>
    </div>
  );
}
