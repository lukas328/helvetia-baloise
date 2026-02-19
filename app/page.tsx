import { PhasePage } from "@/components/phase-page";
import { phases } from "@/lib/phase-config";

export default function Page() {
  return <PhasePage phase={phases[0]} />;
}
