require "services"
require "gds_api_constants"

class ManualPublishingAPIExporter
  def initialize(organisation, manual, version_type: nil)
    @organisation = organisation
    @manual = manual
    @version_type = version_type
  end

  def call
    update_type = case @version_type || manual.version_type
                  when :new, :major
                    GdsApiConstants::PublishingApiV2::MAJOR_UPDATE_TYPE
                  when :minor
                    GdsApiConstants::PublishingApiV2::MINOR_UPDATE_TYPE
                  when :republish
                    GdsApiConstants::PublishingApiV2::REPUBLISH_UPDATE_TYPE
                  else
                    raise "Uknown version type: #{manual.version_type}"
                  end

    base_path = "/#{manual.slug}"
    updates_path = [base_path, GdsApiConstants::PublishingApiV2::UPDATES_PATH_SUFFIX].join("/")

    attributes = {
      base_path: base_path,
      schema_name: GdsApiConstants::PublishingApiV2::MANUAL_SCHEMA_NAME,
      document_type: GdsApiConstants::PublishingApiV2::MANUAL_DOCUMENT_TYPE,
      title: manual.title,
      description: manual.summary,
      update_type: update_type,
      publishing_app: GdsApiConstants::PublishingApiV2::PUBLISHING_APP,
      rendering_app: GdsApiConstants::PublishingApiV2::RENDERING_APP,
      routes: [
        {
          path: base_path,
          type: GdsApiConstants::PublishingApiV2::EXACT_ROUTE_TYPE,
        },
        {
          path: updates_path,
          type: GdsApiConstants::PublishingApiV2::EXACT_ROUTE_TYPE,
        }
      ],
      details: {
        body: [
          {
            content_type: "text/govspeak",
            content: manual.body
          },
          {
            content_type: "text/html",
            content: ManualPresenter.new(manual).body
          }
        ],
        child_section_groups: [
          {
            title: GdsApiConstants::PublishingApiV2::CHILD_SECTION_GROUP_TITLE,
            child_sections: manual.sections.map do |section|
              {
                title: section.title,
                description: section.summary,
                base_path: "/#{section.slug}",
              }
            end,
          }
        ],
        change_notes: manual.publication_logs.map do |publication|
          {
            base_path: "/#{publication.slug}",
            title: publication.title,
            change_note: publication.change_note,
            published_at: publication.published_at,
          }
        end,
        organisations: [
          {
            title: organisation.title,
            abbreviation: organisation.abbreviation,
            web_url: organisation.web_url,
          }
        ]
      },
      locale: GdsApiConstants::PublishingApiV2::EDITION_LOCALE,
    }

    if manual.originally_published_at.present?
      attributes[:first_published_at] = manual.originally_published_at
      if manual.use_originally_published_at_for_public_timestamp?
        attributes[:public_updated_at] = manual.originally_published_at
      end
    end

    Services.publishing_api.put_content(manual.id, attributes)
  end

private

  attr_reader(
    :organisation,
    :manual,
  )
end
