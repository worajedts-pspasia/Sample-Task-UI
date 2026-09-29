import { useCallback, useEffect, useMemo, useState } from "react"
import { Menu, Plus, Search } from "lucide-react"
import { useQueryClient } from "@tanstack/react-query"
import type { ApiTask } from "@/api/types"
import { parsePath, routeToPath, type Route } from "@/routes"
import { Sidebar } from "@/components/things/Sidebar"
import { BottomToolbar } from "@/components/things/BottomToolbar"
import { NewTodoDialog } from "@/components/things/NewTodoDialog"
import { QuickFind } from "@/components/things/QuickFind"
import { useBootstrap, useTaskMutations } from "@/api/hooks"
import { setLocale, type Locale } from "@/i18n"
import { useTranslation } from "react-i18next"
import { ScrollArea } from "@/components/ui/scroll-area"
import { Sheet, SheetContent, SheetTitle } from "@/components/ui/sheet"
import { TooltipProvider } from "@/components/ui/tooltip"
import { Toaster } from "@/components/ui/sonner"
import { TodayView } from "@/views/Today"
import { InboxView } from "@/views/Inbox"
import { UpcomingView } from "@/views/Upcoming"
import { AnytimeView, AreaView, LogbookView, SomedayView, TrashView } from "@/views/Lists"
import { ProjectView } from "@/views/ProjectView"

function titleFor(route: Route, projects: { id: number; name: string }[], areas: { id: number; name: string }[]): string {
  switch (route.kind) {
    case "project":
      return projects.find((p) => p.id === route.id)?.name ?? "List"
    case "area":
      return areas.find((a) => a.id === route.id)?.name ?? "Area"
    default:
      return route.kind.charAt(0).toUpperCase() + route.kind.slice(1)
  }
}

/** Wraps a view and tracks the selected (expanded) task for the toolbar tools. */
export default function App() {
  const [route, setRoute] = useState<Route>(() => parsePath(window.location.pathname))
  const [sheetOpen, setSheetOpen] = useState(false)
  const [todoOpen, setTodoOpen] = useState(false)
  const [todoWhen, setTodoWhen] = useState<"today" | "tomorrow">("today")
  const [findOpen, setFindOpen] = useState(false)
  const [expandedId, setExpandedId] = useState<number | null>(null)
  const qc = useQueryClient()

  // Selected task + its mutations (toolbar tools target it)
  const selected = useMemo<ApiTask | null>(() => {
    if (expandedId == null) return null
    for (const [, data] of qc.getQueriesData({ queryKey: ["tasks"] })) {
      const found = (data as ApiTask[] | undefined)?.find((t) => t.id === expandedId)
      if (found) return found
    }
    return null
  }, [expandedId, qc])
  const selectedMutations = useTaskMutations(selected ?? fakeTask)

  const navigate = useCallback((next: Route) => {
    window.history.pushState(null, "", routeToPath(next))
    setRoute(next)
    setSheetOpen(false)
    setExpandedId(null)
  }, [])

  // Sync language from the signed-in user's preference (once per boot)
  const bootOnce = useBootstrap()
  useEffect(() => {
    const preferred = bootOnce.data?.user.locale as Locale | undefined
    if (preferred && localStorage.getItem("things3-locale") !== preferred) setLocale(preferred)
  }, [bootOnce.data?.user.locale])

  useEffect(() => {
    const onPop = () => setRoute(parsePath(window.location.pathname))
    window.addEventListener("popstate", onPop)
    return () => window.removeEventListener("popstate", onPop)
  }, [])

  const openTodo = (when: "today" | "tomorrow" = "today") => {
    setTodoWhen(when)
    setTodoOpen(true)
  }

  useEffect(() => {
    const onKey = (e: KeyboardEvent) => {
      const meta = e.metaKey || e.ctrlKey
      const target = e.target as HTMLElement | null
      const typing = target && (target.tagName === "INPUT" || target.tagName === "TEXTAREA" || target.isContentEditable)
      // ⌘N matches the Mac app, but browsers reserve it (new window);
      // plain "n" (Gmail-style) always works when not typing.
      if ((meta && e.key.toLowerCase() === "n") || (!meta && !e.altKey && e.key.toLowerCase() === "n" && !typing)) {
        e.preventDefault()
        openTodo()
      } else if ((meta && e.key.toLowerCase() === "k") || (e.altKey && e.code === "Space")) {
        e.preventDefault()
        setFindOpen(true)
      }
    }
    window.addEventListener("keydown", onKey)
    return () => window.removeEventListener("keydown", onKey)
  }, [])

  // coarse names for the mobile top bar
  const bootstrap = qc.getQueryData<{ projects: { id: number; name: string }[]; areas: { id: number; name: string }[] }>(["bootstrap"])

  const rowProps = { expandedId, setExpandedId }

  const content = (() => {
    switch (route.kind) {
      case "today":
        return <TodayView {...rowProps} onNewTodo={(when) => openTodo(when)} />
      case "inbox":
        return <InboxView {...rowProps} />
      case "upcoming":
        return <UpcomingView {...rowProps} onNavigate={navigate} />
      case "anytime":
        return <AnytimeView {...rowProps} onNavigate={navigate} />
      case "someday":
        return <SomedayView {...rowProps} onNavigate={navigate} />
      case "logbook":
        return <LogbookView {...rowProps} />
      case "trash":
        return <TrashView {...rowProps} />
      case "area":
        return <AreaView id={route.id} onNavigate={navigate} />
      case "project":
        return <ProjectView id={route.id} {...rowProps} />
    }
  })()

  return (
    <TooltipProvider delayDuration={350}>
      <div className="h-dvh w-full bg-things-window lg:flex lg:items-center lg:justify-center lg:p-6">
        <div className="relative flex h-full w-full flex-col overflow-hidden bg-white lg:h-[700px] lg:max-w-[1060px] lg:rounded-xl lg:shadow-[0_28px_70px_rgba(0,0,0,0.28)] lg:ring-1 lg:ring-black/10">
          <div className="flex min-h-0 flex-1">
            <aside className="hidden w-[224px] shrink-0 border-r border-things-hairline lg:block">
              <Sidebar route={route} onNavigate={navigate} framed />
            </aside>

            <main className="relative flex min-w-0 flex-1 flex-col">
              {/* Mobile top bar */}
              <div className="flex h-[52px] shrink-0 items-center gap-1 border-b border-things-hairline bg-white/85 px-2 backdrop-blur-md lg:hidden">
                <button
                  type="button"
                  aria-label="Open sidebar"
                  onClick={() => setSheetOpen(true)}
                  className="flex size-9 items-center justify-center rounded-lg text-things-gray-4 transition-colors hover:bg-black/[0.05]"
                >
                  <Menu className="size-5" strokeWidth={1.8} />
                </button>
                <span className="flex-1 truncate text-center text-[15px] font-semibold tracking-[-0.01em] text-things-title">
                  {titleFor(route, bootstrap?.projects ?? [], bootstrap?.areas ?? [])}
                </span>
                <button
                  type="button"
                  aria-label="Quick find"
                  onClick={() => setFindOpen(true)}
                  className="flex size-9 items-center justify-center rounded-lg text-things-gray-4 transition-colors hover:bg-black/[0.05]"
                >
                  <Search className="size-[18px]" strokeWidth={1.8} />
                </button>
                <button
                  type="button"
                  aria-label="New to-do"
                  onClick={() => openTodo()}
                  className="flex size-9 items-center justify-center rounded-lg text-things-gray-4 transition-colors hover:bg-black/[0.05]"
                >
                  <Plus className="size-5" strokeWidth={1.9} />
                </button>
              </div>

              {/* Desktop toolbar */}
              <div className="hidden h-[46px] shrink-0 items-center justify-end gap-1 px-4 lg:flex">
                <button
                  type="button"
                  aria-label="Quick find"
                  onClick={() => setFindOpen(true)}
                  className="flex size-8 items-center justify-center rounded-lg text-things-gray-4 transition-colors hover:bg-black/[0.05]"
                >
                  <Search className="size-[17px]" strokeWidth={1.8} />
                </button>
                <button
                  type="button"
                  aria-label="New to-do"
                  onClick={() => openTodo()}
                  className="flex size-8 items-center justify-center rounded-[10px] border border-things-border text-things-gray-4 shadow-[inset_0_1px_0_rgba(255,255,255,0.6)] transition-colors hover:bg-things-hover"
                >
                  <Plus className="size-[17px]" strokeWidth={2} />
                </button>
              </div>

              <ScrollArea className="min-h-0 flex-1">
                <div className="mx-auto w-full max-w-[640px] px-2 pb-6">{content}</div>
              </ScrollArea>

              <div className="shrink-0 pb-[env(safe-area-inset-bottom)] lg:hidden">
                <BottomToolbar
                  onNewTodo={() => openTodo()}
                  onQuickFind={() => setFindOpen(true)}
                  hasSelection={Boolean(selected)}
                  onSchedule={() => selectedMutations.schedule(new Date().toISOString().slice(0, 10))}
                  onDeadline={() => selectedMutations.setDeadline(new Date().toISOString().slice(0, 10))}
                  onChecklist={() => selectedMutations.addChecklistItem("")}
                />
              </div>
              <div className="absolute bottom-4 left-4 hidden lg:block">
                <BottomToolbar
                  floating
                  onNewTodo={() => openTodo()}
                  onQuickFind={() => setFindOpen(true)}
                  hasSelection={Boolean(selected)}
                  onSchedule={() => selectedMutations.schedule(new Date().toISOString().slice(0, 10))}
                  onDeadline={() => selectedMutations.setDeadline(new Date().toISOString().slice(0, 10))}
                  onChecklist={() => selectedMutations.addChecklistItem("")}
                />
              </div>
            </main>
          </div>
        </div>

        <Sheet open={sheetOpen} onOpenChange={setSheetOpen}>
          <SheetContent
            side="left"
            showCloseButton={false}
            className="w-[286px] gap-0 border-r border-things-hairline bg-things-sidebar p-0 shadow-[0_0_60px_rgba(0,0,0,0.18)]"
          >
            <SheetTitle className="sr-only">Sidebar</SheetTitle>
            <Sidebar route={route} onNavigate={navigate} />
          </SheetContent>
        </Sheet>
      </div>

      <NewTodoDialog key={todoWhen} open={todoOpen} onOpenChange={setTodoOpen} defaultWhen={todoWhen} />
      <QuickFind open={findOpen} onOpenChange={setFindOpen} onNavigate={navigate} />
      <Toaster position="bottom-center" richColors={false} />
    </TooltipProvider>
  )
}

// placeholder so useTaskMutations always receives a task shape (never used when null)
const fakeTask: ApiTask = {
  id: 0, title: "", notes: null, when_date: null, reminder_at: null, evening: false,
  deadline_date: null, status: "open", someday: false, trashed: false, completed_at: null,
  position: 0, project_id: null, area_id: null, heading_id: null, tags: [], checklist_items: [],
}
