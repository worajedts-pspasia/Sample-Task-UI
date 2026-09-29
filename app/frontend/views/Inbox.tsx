import { useTranslation } from "react-i18next"
import { useTasks } from "@/api/hooks"
import { TaskRow } from "@/components/things/TaskRow"
import { ViewHeader } from "@/views/parts"

export function InboxView({ expandedId, setExpandedId }: { expandedId: number | null; setExpandedId: (id: number | null) => void }) {
  const { t } = useTranslation()
  const { data: tasks, isLoading } = useTasks("inbox")
  return (
    <div>
      <ViewHeader title="Inbox" subtitle={t("view.toDos", { count: tasks?.length ?? 0 })} />
      {isLoading && <p className="px-3 pt-4 text-[13px] text-things-gray">{t("view.loading")}</p>}
      {!isLoading && (tasks ?? []).length === 0 && <p className="px-3 pt-4 text-[13px] text-things-gray">{t("view.inboxEmpty")}</p>}
      {(tasks ?? []).map((task) => (
        <TaskRow
          key={task.id}
          task={task}
          expanded={expandedId === task.id}
          onExpand={() => setExpandedId(expandedId === task.id ? null : task.id)}
        />
      ))}
    </div>
  )
}
