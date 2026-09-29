import { parseISO } from "date-fns"
import { useTranslation } from "react-i18next"
import i18n from "@/i18n"
import { monthLong, weekdayShort } from "@/lib/dates"
import { useTasks } from "@/api/hooks"
import type { ApiTask } from "@/api/types"
import type { Route } from "@/routes"
import { TaskRow } from "@/components/things/TaskRow"
import { GroupLabel, ViewHeader } from "@/views/parts"

type Day = { key: string; month: string; weekday: string; day: number; tasks: ApiTask[] }

const dateOf = (t: ApiTask) => t.when_date ?? t.deadline_date ?? "9999-12-31"

function groupByDay(tasks: ApiTask[]): Day[] {
  const days = new Map<string, ApiTask[]>()
  for (const t of tasks) {
    const key = dateOf(t)
    if (!days.has(key)) days.set(key, [])
    days.get(key)!.push(t)
  }
  return [...days.entries()]
    .sort(([a], [b]) => a.localeCompare(b))
    .map(([key, list]) => {
      const date = parseISO(key)
      return {
        key,
        month: monthLong(date, i18n.language),
        weekday: weekdayShort(date, i18n.language),
        day: date.getDate(),
        tasks: list,
      }
    })
}

export function UpcomingView({
  expandedId,
  setExpandedId,
  onNavigate,
}: {
  expandedId: number | null
  setExpandedId: (id: number | null) => void
  onNavigate: (route: Route) => void
}) {
  const { t } = useTranslation()
  const { data: tasks, isLoading } = useTasks("upcoming")
  const days = groupByDay(tasks ?? [])
  let lastMonth = ""

  return (
    <div>
      <ViewHeader title="Upcoming" subtitle={t("view.scheduled", { count: (tasks ?? []).length })} />
      {isLoading && <p className="px-3 pt-4 text-[13px] text-things-gray">{t("view.loading")}</p>}
      {!isLoading && days.length === 0 && <p className="px-3 pt-4 text-[13px] text-things-gray">{t("view.upcomingEmpty")}</p>}
      {days.map((d) => {
        const monthHeader = d.month !== lastMonth ? d.month : null
        lastMonth = d.month
        return (
          <div key={d.key}>
            {monthHeader && <GroupLabel>{monthHeader}</GroupLabel>}
            <div className="flex items-start gap-2 px-3 py-1">
              <div className="flex w-[38px] shrink-0 flex-col items-end pt-[7px] pb-1">
                <span className="text-[10.5px] font-medium uppercase tracking-wide text-things-gray">{d.weekday}</span>
                <span className="text-[15px] font-semibold leading-tight text-things-ink tabular-nums">{d.day}</span>
              </div>
              <div className="min-w-0 flex-1">
                {d.tasks.map((task) => (
                  <TaskRow
                    key={task.id}
                    task={task}
                    expanded={expandedId === task.id}
                    onExpand={() => setExpandedId(expandedId === task.id ? null : task.id)}
                  />
                ))}
              </div>
            </div>
          </div>
        )
      })}
      <div className="h-8" />
    </div>
  )
}
