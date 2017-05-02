require "spec_helper"

RSpec.describe PublicationLogger do
  let(:slug_generator) { SlugGenerator.new(prefix: "manual-slug") }
  let(:manual) { double(:manual, sections: sections, removed_sections: []) }
  let(:sections) { [section] }
  let(:section) { Section.new(slug_generator, "section-id-1", [section_edition]) }
  let(:section_edition) { FactoryGirl.create(:section_edition) }

  describe "call" do
    it "creates a PublicationLog for each Section" do
      expect {
        subject.call(manual)
      }.to change(PublicationLog, :count).by(1)
    end

    # It's possible to pass a nil change_note, this indicates that the section
    # update is not to be logged by the PublicationLogger
    context "when a section edition has no change note" do
      let(:cloned_section) { Section.new(slug_generator, "section-id-2", [cloned_section_edition]) }
      let(:cloned_section_edition) { FactoryGirl.create(:section_edition, change_note: nil) }
      let(:sections) { [section, cloned_section] }
      it "does not create a PublicationLog for a cloned Section" do
        expect {
          subject.call(manual)
        }.to change(PublicationLog, :count).by(1)

        expect {
          PublicationLog.find_by(change_note: nil)
        }.to raise_error(Mongoid::Errors::DocumentNotFound)
      end
    end
  end
end