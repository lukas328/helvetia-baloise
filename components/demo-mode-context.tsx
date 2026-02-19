"use client";
import { createContext, useContext, useState } from "react";

const DemoModeContext = createContext({ demoMode: false, setDemoMode: (_v: boolean) => {} });

export const useDemoMode = () => useContext(DemoModeContext);

export function DemoModeProvider({ children }: { children: React.ReactNode }) {
  const [demoMode, setDemoMode] = useState(false);
  return <DemoModeContext.Provider value={{ demoMode, setDemoMode }}>{children}</DemoModeContext.Provider>;
}
