import { format } from "date-fns"
import { useTranslation } from "react-i18next"
import { ChevronRight, RotateCcw, Tag, Trash2 } from "lucide-react"
import { useArea, useBootstrap, useEmptyTrash, useRestoreTask, useTasks } from "@/api/hooks"
import type { Route } from "@/routes"
import { TaskRow } from "@/components/things/TaskRow"
import { GroupLabel, ProjectHeader, Sep, ViewHeader } from "@/views/parts"
import { ListGlyph } from "@/components/things/icons"
import { Button } from "@/components/ui/button"

type RowProps = { expandedId: number | null; setExpandedId: (id: number | null) => void }

export function AnytimeView({ expandedId, setExpandedId, onNavigate }: RowProps & { onNavigate: (route: Route) => void }) {
  const { t } = useTranslation()
  const { data: boot } = useBootstrap()
  const { data: tasks, isLoading } = useTasks("anytime")
  const all = tasks ?? []
  const todays = all.filter((t) => t.when_date && t.when_date <= format(new Date(), "yyyy-MM-dd"))
  const inbox = all.filter((t) => !t.project_id && !t.area_id && (!t.when_date || t.when_date > format(new Date(), "yyyy-MM-dd")))
  const withProject = all.filter((t) => t.project_id)

  return (
    <div>
      <ViewHeader title="Anytime" subtitle={t("view.remaining", { count: all.length })} />
      {isLoading && <p className="px-3 pt-4 text-[13px] text-things-gray">{t("view.loading")}</p>}
      <Sep label={t("sidebar.today")} />
      {todays.map((task) => (
        <TaskRow key={task.id} task={task} expanded={expandedId === task.id} onExpand={() => setExpandedId(expandedId === task.id ? null : task.id)} />
      ))}
      <Sep label={t("sidebar.inbox")} />
      {inbox.map((task) => (
        <TaskRow key={task.id} task={task} expanded={expandedId === task.id} onExpand={() => setExpandedId(expandedId === task.id ? null : task.id)} />
      ))}
      {(boot?.projects ?? []).map((project) => {
        const list = withProject.filter((t) => t.project_id === project.id)
        if (list.length === 0) return null
        return (
          <div key={project.id}>
            <ProjectHeader
              project={project}
              remaining={list.filter((t) => t.status === "open").length}
              onOpen={() => onNavigate({ kind: "project", id: project.id })}
            />
            {list.map((task) => (
              <TaskRow key={task.id} task={task} expanded={expandedId === task.id} onExpand={() => setExpandedId(expandedId === task.id ? null : task.id)} />
            ))}
          </div>
        )
      })}
      <div className="h-8" />
    </div>
  )
}

export function SomedayView({ expandedId, setExpandedId, onNavigate }: RowProps & { onNavigate: (route: Route) => void }) {
  const { t } = useTranslation()
  const { data: boot } = useBootstrap()
  const { data: tasks, isLoading } = useTasks("someday")
  const all = tasks ?? []
  const loose = all.filter((t) => !t.project_id)

  return (
    <div>
      <ViewHeader title="Someday" subtitle={t("view.toDos", { count: all.length })} />
      {isLoading && <p className="px-3 pt-4 text-[13px] text-things-gray">{t("view.loading")}</p>}
      {!isLoading && all.length === 0 && <p className="px-3 pt-4 text-[13px] text-things-gray">{t("view.somedayEmpty")}</p>}
      {(boot?.projects ?? []).map((project) => {
        const list = all.filter((t) => t.project_id === project.id)
        if (list.length === 0) return null
        return (
          <div key={project.id}>
            <ProjectHeader project={project} remaining={0} onOpen={() => onNavigate({ kind: "project", id: project.id })} />
            {list.map((task) => (
              <TaskRow key={task.id} task={task} expanded={expandedId === task.id} onExpand={() => setExpandedId(expandedId === task.id ? null : task.id)} />
            ))}
          </div>
        )
      })}
      {loose.length > 0 && <GroupLabel>{t("view.noProject")}</GroupLabel>}
      {loose.map((task) => (
        <TaskRow key={task.id} task={task} expanded={expandedId === task.id} onExpand={() => setExpandedId(expandedId === task.id ? null : task.id)} />
      ))}
      <div className="h-8" />
    </div>
  )
}

export function LogbookView({ expandedId, setExpandedId }: RowProps) {
  const { t } = useTranslation()
  const { data: tasks, isLoading } = useTasks("logbook")
  const all = tasks ?? []
  const thisWeek = all.filter((t) => t.completed_at && Date.now() - new Date(t.completed_at).getTime() < 7 * 86400_000)
  const earlier = all.filter((t) => !thisWeek.includes(t))

  return (
    <div>
      <ViewHeader title="Logbook" subtitle={t("view.completed", { count: all.length })} />
      {isLoading && <p className="px-3 pt-4 text-[13px] text-things-gray">{t("view.loading")}</p>}
      {thisWeek.length > 0 && <GroupLabel>{t("view.thisWeek")}</GroupLabel>}
      {thisWeek.map((task) => (
        <TaskRow key={task.id} task={task} expanded={expandedId === task.id} onExpand={() => setExpandedId(expandedId === task.id ? null : task.id)} />
      ))}
      {earlier.length > 0 && <GroupLabel>{t("view.earlier")}</GroupLabel>}
      {earlier.map((task) => (
        <TaskRow key={task.id} task={task} expanded={expandedId === task.id} onExpand={() => setExpandedId(expandedId === task.id ? null : task.id)} />
      ))}
      <div className="h-8" />
    </div>
  )
}

export function TrashView(_props: RowProps) {
  const { t } = useTranslation()
  const { data: tasks, isLoading } = useTasks("trash")
  const empty = useEmptyTrash()
  const restore = useRestoreTask()
  const all = tasks ?? []

  return (
    <div>
      <ViewHeader
        title="Trash"
        right={
          all.length > 0 ? (
            <Button
              variant="outline"
              size="sm"
              className="h-7 border-things-badge/30 text-[12px] text-things-badge hover:bg-things-badge/5"
              onClick={() => empty.mutate()}
            >
              {t("view.emptyTrash")}
            </Button>
          ) : undefined
        }
      />
      {isLoading && <p className="px-3 pt-4 text-[13px] text-things-gray">{t("view.loading")}</p>}
      {!isLoading && all.length === 0 && (
        <div className="flex flex-col items-center gap-3 pt-32 text-things-gray">
          <Trash2 className="size-10" strokeWidth={1.4} />
          <p className="text-[13px]">{t("view.trashEmpty")}</p>
        </div>
      )}
      {all.map((task) => (
        <div key={task.id} className="group flex items-center gap-2 rounded-lg px-3 py-[7px] hover:bg-things-hover">
          <Trash2 className="size-[15px] shrink-0 text-things-gray" strokeWidth={1.8} />
          <p className="flex-1 truncate text-[14.5px] text-things-gray">{task.title}</p>
          <Button
            variant="ghost"
            size="sm"
            className="h-7 gap-1 px-2 text-[12px] text-things-gray-4 opacity-0 transition-opacity group-hover:opacity-100 hover:text-things-blue"
            onClick={() => restore.mutate(task.id)}
          >
            <RotateCcw className="size-3.5" /> {t("view.restore")}
          </Button>
        </div>
      ))}
      <div className="h-8" />
    </div>
  )
}

export function AreaView({ id, onNavigate }: { id: number; onNavigate: (route: Route) => void }) {
  const { t } = useTranslation()
  const { data: boot } = useBootstrap()
  const { data: area, isLoading } = useArea(id)
  const areaProjects = (boot?.projects ?? []).filter((p) => p.area_id === id)

  return (
    <div>
      <ViewHeader icon={<Tag className="size-[19px] text-things-gray-2" strokeWidth={1.8} />} title={boot?.areas.find((a) => a.id === id)?.name ?? "Area"} />
      <GroupLabel>{t("view.projects")}</GroupLabel>
      <div className="flex flex-col px-3">
        {areaProjects.map((project) => (
          <button
            key={project.id}
            type="button"
            onClick={() => onNavigate({ kind: "project", id: project.id })}
            className="flex items-center gap-3 rounded-lg py-[7px] text-left transition-colors hover:bg-things-hover"
          >
            <ListGlyph color={project.color} className="size-[19px] rounded-md" />
            <span className="flex-1 truncate text-[14.5px] text-things-ink">{project.name}</span>
            <span className="text-[12px] tabular-nums text-things-gray">{project.open_count}</span>
            <ChevronRight className="size-4 text-things-box" />
          </button>
        ))}
        {areaProjects.length === 0 && <p className="py-1 text-[13px] text-things-gray">{t("view.noListsInArea")}</p>}
      </div>
      <GroupLabel>{t("view.toDosSection")}</GroupLabel>
      {isLoading && <p className="px-3 pt-2 text-[13px] text-things-gray">{t("view.loading")}</p>}
      {(area?.tasks ?? []).filter((t) => !t.project_id).map((task) => (
        <TaskRow key={task.id} task={task} />
      ))}
      <div className="h-8" />
    </div>
  )
}
