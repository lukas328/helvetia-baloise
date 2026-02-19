import { cn } from "@/lib/utils";
import { HTMLAttributes, TableHTMLAttributes } from "react";

export const Table = (props: TableHTMLAttributes<HTMLTableElement>) => <table className={cn("w-full text-sm", props.className)} {...props} />;
export const THead = (props: HTMLAttributes<HTMLTableSectionElement>) => <thead {...props} />;
export const TBody = (props: HTMLAttributes<HTMLTableSectionElement>) => <tbody {...props} />;
export const TR = (props: HTMLAttributes<HTMLTableRowElement>) => <tr className={cn("border-b border-border", props.className)} {...props} />;
export const TH = (props: HTMLAttributes<HTMLTableCellElement>) => <th className={cn("px-3 py-2 text-left text-xs uppercase text-muted", props.className)} {...props} />;
export const TD = (props: HTMLAttributes<HTMLTableCellElement>) => <td className={cn("px-3 py-2", props.className)} {...props} />;
