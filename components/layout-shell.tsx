"use client";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { phases } from "@/lib/phase-config";
import { Badge } from "@/components/ui/badge";
import { cn } from "@/lib/utils";

export function LayoutShell({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();
  const current = phases.find((p) => p.route === pathname) ?? phases[0];
  return (
    <div className="min-h-screen bg-background text-foreground">
      <aside className="fixed left-0 top-0 h-screen w-[280px] overflow-y-auto border-r border-border bg-[#0d1628] p-4">
        <div className="mb-6 text-lg font-semibold">mesoneer | AI Speedboat</div>
        <nav className="space-y-2">
          {phases.map((item) => (
            <Link key={item.route} href={item.route} className={cn("block rounded-lg border border-transparent p-3", pathname === item.route ? "border-border bg-card" : "hover:border-border") }>
              <div className="flex items-center justify-between gap-2">
                <span className="text-sm">{item.navTitle}</span>
                <Badge className="text-[10px]">{item.phaseBadge}</Badge>
              </div>
              <p className="mt-1 text-xs text-muted">{item.miniStatus}</p>
            </Link>
          ))}
        </nav>
      </aside>
      <main className="ml-[280px]">
        <header className="sticky top-0 z-20 flex h-16 items-center justify-between border-b border-border bg-background/90 px-6 backdrop-blur">
          <p className="text-sm text-muted">WHAT › Vorgehensmodell › {current.phaseBadge === "OV" ? "Overview" : `Phase ${current.phaseBadge}`}</p>
          {children}
        </header>
      </main>
    </div>
  );
}
