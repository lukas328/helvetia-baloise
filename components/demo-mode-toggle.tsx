"use client";
import { useDemoMode } from "@/components/demo-mode-context";

export function DemoModeToggle() {
  const { demoMode, setDemoMode } = useDemoMode();
  return (
    <button onClick={() => setDemoMode(!demoMode)} className={`rounded-full border px-3 py-1 text-xs ${demoMode ? "border-accent text-accent" : "border-border text-muted"}`}>
      Demo Mode {demoMode ? "ON" : "OFF"}
    </button>
  );
}
