module MedicalSafetyAlertImport
  class Mapper
    def initialize(document_creator, document_publisher, repo)
      @document_creator = document_creator
      @document_publisher = document_publisher
      @repo = repo
    end

    def call(raw_data)
      document = document_creator.call(desired_attributes(raw_data))
      document = document_publisher.call(document.id)
      document
    end

    def import_notes
      []
    end

  private
    attr_reader :document_creator, :document_publisher, :repo

    def desired_attributes(data)
      massage(data)
        .slice(*desired_keys)
        .symbolize_keys
    end

    def massage(data)
      alert_type = case data["import_source"]
                   when /safety-information-from-manufacturers-field-safety-notices/
                     "field-safety"
                   when /medicines-company-led-recalls/
                     "company-led-drug"
                   end

      title_date = /\d\d? \w+ 2015/.match(data["title"])
      begin
        issued_date = Date.parse(title_date[0])
      rescue ArgumentError
        issued_date = Date.parse(data["issued_date"])
      end

      data.merge(
        "alert_type" => alert_type,
        "issued_date" => issued_date.strftime("%Y-%m-%d"),
      )
    end

    def desired_keys
      %w(
        body
        title
        alert_type
        issued_date
        summary
      )
    end
  end
end
