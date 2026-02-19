"use client";

import { useState } from "react";
import { cn } from "@/lib/utils";

export function Accordion({ items }: { items: { title: string; content: string[] }[] }) {
  const [open, setOpen] = useState<number | null>(0);
  return (
    <div className="space-y-2">
      {items.map((item, idx) => (
        <div key={item.title} className="rounded-lg border border-border">
          <button className="w-full px-3 py-2 text-left text-sm font-medium" onClick={() => setOpen(open === idx ? null : idx)}>
            {item.title}
          </button>
          <div className={cn("grid transition-all", open === idx ? "grid-rows-[1fr]" : "grid-rows-[0fr]")}>
            <div className="overflow-hidden">
              <ul className="list-disc space-y-1 px-7 pb-3 text-sm text-muted">
                {item.content.map((entry) => <li key={entry}>{entry}</li>)}
              </ul>
            </div>
          </div>
        </div>
      ))}
    </div>
  );
}
