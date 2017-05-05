require "markdown_attachment_processor"
require "govspeak_to_html_renderer"
require "footnotes_section_heading_renderer"

class SectionPresenter
  def initialize(section)
    @section = section
  end

  delegate :slug, to: :@section
  delegate :title, to: :@section
  delegate :summary, to: :@section
  delegate :valid?, to: :@section
  delegate :errors, to: :@section

  def body
    pipeline = [
      MarkdownAttachmentProcessor.method(:new),
      GovspeakToHTMLRenderer.create,
      FootnotesSectionHeadingRenderer.create,
    ]

    pipeline.reduce(@section) { |current_section, next_renderer|
      next_renderer.call(current_section)
    }.attributes.fetch(:body)
  end
end