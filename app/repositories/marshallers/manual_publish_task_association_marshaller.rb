class ManualPublishTaskAssociationMarshaller
  def load(manual, _edition)
    tasks = ManualPublishTask.for_manual(manual)

    ManualWithPublishTasks.new(manual, publish_tasks: tasks)
  end

  def dump(_manual, _edition)
    # PublishTasks are read only
    nil
  end
end
