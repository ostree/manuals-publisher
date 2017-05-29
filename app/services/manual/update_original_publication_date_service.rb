require "adapters"

class Manual::UpdateOriginalPublicationDateService
  def initialize(user:, manual_id:, attributes:)
    @user = user
    @manual_id = manual_id
    @attributes = attributes.slice(:originally_published_at, :use_originally_published_at_for_public_timestamp)
  end

  def call
    manual.draft
    manual.update(attributes)
    manual.sections.each do |section|
      # a nil change note will omit this update from publication logs
      section.update(change_note: nil)
    end
    persist

    Adapters.publishing.save(manual)

    manual
  end

private

  attr_reader :user, :manual_id, :attributes

  def persist
    manual.save(user)
    @manual = Manual.find(manual_id, user)
  end

  def manual
    @manual ||= Manual.find(manual_id, user)
  end
end
