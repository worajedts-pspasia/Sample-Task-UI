import { useState } from "react"
import { useTranslation } from "react-i18next"
import { format } from "date-fns"
import { useProject } from "@/api/hooks"
import { TaskRow, HeaderMenu } from "@/components/things/TaskRow"
import { Sep, ViewHeader } from "@/views/parts"
import { ProgressPie } from "@/components/things/icons"
import { cn } from "@/lib/utils"

type Filter = "all" | "open" | "scheduled"

const FILTERS: { id: Filter; label: string }[] = [
  { id: "all", label: "all" },
  { id: "open", label: "open" },
  { id: "scheduled", label: "scheduled" },
]

export function ProjectView({ id, expandedId, setExpandedId }: { id: number; expandedId: number | null; setExpandedId: (id: number | null) => void }) {
  const { t } = useTranslation()
  const { data: project, isLoading } = useProject(id)
  const [filter, setFilter] = useState<Filter>("all")

  if (isLoading || !project) {
    return (
      <div>
        <ViewHeader title="List" />
        <p className="px-3 pt-4 text-[13px] text-things-gray">{t("view.loading")}</p>
      </div>
    )
  }

  const tasks = project.tasks.filter((t) => {
    if (filter === "open") return t.status === "open"
    if (filter === "scheduled") return Boolean(t.when_date || t.deadline_date)
    return true
  })
  const byHeading = tasks.filter((t) => t.heading_id)
  const plain = tasks.filter((t) => !t.heading_id)
  const openCount = project.tasks.filter((t) => t.status === "open").length

  return (
    <div>
      <ViewHeader
        icon={
          <ProgressPie
            fraction={(project.total_count - openCount) / Math.max(1, project.total_count)}
            size={22}
          />
        }
        title={project.name}
        subtitle={project.notes ?? t("view.openCount", { count: openCount })}
        right={<HeaderMenu />}
      />
      <div className="flex items-center gap-1.5 px-3 pb-1">
        {FILTERS.map((f) => (
          <button
            key={f.id}
            type="button"
            onClick={() => setFilter(f.id)}
            className={cn(
              "h-[23px] rounded-full px-2.5 text-[11.5px] font-medium transition-colors",
              filter === f.id ? "bg-things-chip text-things-title" : "text-things-gray-2 hover:bg-black/[0.04]",
            )}
          >
            {t(`view.${f.label}`)}
          </button>
        ))}
        <span className="ml-auto text-[12px] tabular-nums text-things-gray">{t("view.openCount", { count: openCount })}</span>
      </div>
      {plain.map((task) => (
        <TaskRow
          key={task.id}
          task={task}
          expanded={expandedId === task.id}
          onExpand={() => setExpandedId(expandedId === task.id ? null : task.id)}
        />
      ))}
      {project.headings.map((heading) => {
        const list = byHeading.filter((t) => t.heading_id === heading.id)
        if (list.length === 0) return null
        return (
          <div key={heading.id}>
            <Sep label={heading.name} />
            {list.map((task) => (
              <TaskRow
                key={task.id}
                task={task}
                expanded={expandedId === task.id}
                onExpand={() => setExpandedId(expandedId === task.id ? null : task.id)}
              />
            ))}
          </div>
        )
      })}
      <div className="h-8" />
    </div>
  )
}
