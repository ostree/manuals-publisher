require "securerandom"

class ManualBuilder
  def initialize
    @slug_generator = SlugGenerator.new(prefix: "guidance")
    @factory = ->(attrs) {
      manual = Manual.new(attrs)
      manual.sections = attrs.fetch(:sections, [])
      manual.removed_sections = attrs.fetch(:removed_sections, [])
      manual
    }
  end

  def call(attrs)
    default_attrs = {
      id: SecureRandom.uuid,
      slug: slug_generator.call(attrs.fetch(:title)),
      summary: "",
      body: "",
      state: "draft",
      organisation_slug: "",
      updated_at: "",
      originally_published_at: nil,
      use_originally_published_at_for_public_timestamp: true,
    }

    factory.call(default_attrs.merge(attrs))
  end

private

  attr_reader :slug_generator, :factory
end
