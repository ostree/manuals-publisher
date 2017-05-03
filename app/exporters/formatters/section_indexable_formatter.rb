require "formatters/abstract_indexable_formatter"

class SectionIndexableFormatter < AbstractIndexableFormatter
  RUMMAGER_DOCUMENT_TYPE = "manual_section".freeze

  def initialize(section, manual)
    @entity = section
    @manual = manual
  end

  def type
    RUMMAGER_DOCUMENT_TYPE
  end

  def indexable_attributes
    {
      title: "#{manual.title}: #{entity.title}",
      description: description,
      link: link,
      indexable_content: indexable_content,
      public_timestamp: public_timestamp,
      content_store_document_type: type,
      manual: manual_slug
    }
  end

private

  attr_reader :manual

  def manual_slug
    with_leading_slash(manual.slug)
  end

  def description
    entity.summary
  end

  def link
    with_leading_slash(entity.slug)
  end

  def indexable_content
    entity.body
  end

  def public_timestamp
    nil
  end
end
