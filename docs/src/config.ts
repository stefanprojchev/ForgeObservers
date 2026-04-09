export type NavItem = { title: string; href: string };
export type NavGroup = { title: string; children: NavItem[] };
export type NavEntry = NavItem | NavGroup;

export function isNavGroup(entry: NavEntry): entry is NavGroup {
  return "children" in entry;
}

export const siteConfig = {
  name: "ForgeObservers",
  description: "Reactive system observers for iOS — connectivity, lifecycle, keyboard, appearance, and more",
  github: "https://github.com/stefanprojchev/ForgeObservers",
  nav: {
    docs: [
      { title: "Getting Started", href: "docs/getting-started" },
      {
        title: "Observers",
        children: [
          { title: "Connectivity", href: "docs/connectivity" },
          { title: "App Lifecycle", href: "docs/app-lifecycle" },
          { title: "Keyboard", href: "docs/keyboard" },
          { title: "Appearance", href: "docs/appearance" },
          { title: "Locale", href: "docs/locale" },
          { title: "Protected Data", href: "docs/protected-data" },
          { title: "Notification Permission", href: "docs/notification-permission" },
        ],
      },
      { title: "Async Streams", href: "docs/async-streams" },
      { title: "Assign Extension", href: "docs/assign-extension" },
    ] as NavEntry[],
    examples: [
      {
        title: "Basic Usage",
        children: [
          { title: "Connectivity", href: "examples/connectivity" },
          { title: "App Lifecycle", href: "examples/app-lifecycle" },
          { title: "Keyboard", href: "examples/keyboard" },
          { title: "Appearance", href: "examples/appearance" },
          { title: "Locale", href: "examples/locale" },
          { title: "Protected Data", href: "examples/protected-data" },
          { title: "Notification Permission", href: "examples/notification-permission" },
        ],
      },
      { title: "ViewModel Integration", href: "examples/viewmodel-integration" },
      { title: "With ForgeInject", href: "examples/with-forge-inject" },
    ] as NavEntry[],
  },
};

export const proseClasses = "prose prose-neutral dark:prose-invert prose-headings:font-semibold prose-headings:tracking-tight prose-h1:text-2xl prose-h1:mb-2 prose-h2:mt-10 prose-h2:text-lg prose-h2:border-b prose-h2:border-border/60 prose-h2:pb-2 prose-h3:text-base prose-p:text-[15px] prose-p:leading-relaxed prose-code:rounded prose-code:bg-muted prose-code:px-1.5 prose-code:py-0.5 prose-code:font-mono prose-code:text-[13px] prose-code:font-normal prose-code:before:content-none prose-code:after:content-none prose-pre:bg-transparent prose-pre:p-0 prose-a:text-orange-600 prose-a:no-underline hover:prose-a:underline dark:prose-a:text-amber-400 max-w-none";

/** Resolve a nav href to a full path including base URL */
export function resolveHref(href: string): string {
  const base = import.meta.env.BASE_URL.replace(/\/$/, "");
  return `${base}/${href}`;
}
