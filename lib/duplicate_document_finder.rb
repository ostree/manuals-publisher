class DuplicateDocumentFinder
  def initialize(io = STDOUT)
    @io = io
  end

  def execute
    slug_hash = {}
    SectionEdition.all.each do |edition|
      slug_hash[edition.slug] ||= {}
      slug_hash[edition.slug][edition.document_id] ||= { state: edition.state, created_at: edition.created_at, editions: 0 }
      slug_hash[edition.slug][edition.document_id][:editions] += 1
    end

    slug_hash.reject! { |_slug, document_ids| document_ids.size == 1 }

    slug_hash.each do |slug, sections|
      sections.each do |document_id, data|
        @io.puts [slug, document_id, data[:state], data[:created_at], data[:editions]].join(",")
      end
    end
  end
end