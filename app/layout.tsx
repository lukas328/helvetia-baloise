import "./globals.css";
import { LayoutShell } from "@/components/layout-shell";
import { DemoModeProvider } from "@/components/demo-mode-context";
import { DemoModeToggle } from "@/components/demo-mode-toggle";

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="de" className="dark">
      <body>
        <DemoModeProvider>
          <LayoutShell>
            <DemoModeToggle />
          </LayoutShell>
          <div className="ml-[280px] p-6">{children}</div>
        </DemoModeProvider>
      </body>
    </html>
  );
}
