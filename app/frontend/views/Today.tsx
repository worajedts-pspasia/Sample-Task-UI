import { Plus } from "lucide-react"
import { useTranslation } from "react-i18next"
import i18n from "@/i18n"
import { longDate } from "@/lib/dates"
import { useBootstrap, useTasks } from "@/api/hooks"
import type { ApiTask } from "@/api/types"
import { TaskRow } from "@/components/things/TaskRow"
import { Sep, ViewHeader } from "@/views/parts"
import { StarGlyph } from "@/components/things/icons"

export function TodayView({
  expandedId,
  setExpandedId,
  onNewTodo,
}: {
  expandedId: number | null
  setExpandedId: (id: number | null) => void
  onNewTodo: (when: "tomorrow") => void
}) {
  const { t } = useTranslation()
  const { data: boot } = useBootstrap()
  const { data: tasks, isLoading } = useTasks("today")

  const day = (tasks ?? []).filter((t) => !t.evening)
  const evening = (tasks ?? []).filter((t) => t.evening)
  const context = (t: ApiTask) => {
    const name = boot?.projects.find((p) => p.id === t.project_id)?.name ?? boot?.areas.find((a) => a.id === t.area_id)?.name
    return name ?? undefined
  }

  return (
    <div>
      <ViewHeader
        icon={<StarGlyph className="size-[22px]" />}
        title="Today"
        subtitle={longDate(new Date(), i18n.language)}
      />
      {isLoading ? (
        <p className="px-3 pt-4 text-[13px] text-things-gray">{t("view.loading")}</p>
      ) : day.length === 0 && evening.length === 0 ? (
        <p className="px-3 pt-4 text-[13px] text-things-gray">{t("view.todayEmpty")}</p>
      ) : null}
      {day.map((task) => (
        <TaskRow
          key={task.id}
          task={task}
          contextLabel={context(task)}
          expanded={expandedId === task.id}
          onExpand={() => setExpandedId(expandedId === task.id ? null : task.id)}
        />
      ))}
      {evening.length > 0 && (
        <>
          <Sep label={t("view.thisEvening")} moon />
          {evening.map((task) => (
            <TaskRow
              key={task.id}
              task={task}
              contextLabel={context(task)}
              expanded={expandedId === task.id}
              onExpand={() => setExpandedId(expandedId === task.id ? null : task.id)}
            />
          ))}
        </>
      )}

      <div className="px-3 pt-6 pb-4">
        <button type="button" onClick={() => onNewTodo("tomorrow")} className="flex items-center gap-3 rounded-lg py-1.5 text-left">
          <span className="flex size-[19px] items-center justify-center rounded-full border-[1.5px] border-dashed border-things-box text-things-gray">
            <Plus className="size-[11px]" strokeWidth={2.2} />
          </span>
          <span className="text-[13px] text-things-gray">{t("view.tomorrow")}</span>
        </button>
      </div>
    </div>
  )
}
