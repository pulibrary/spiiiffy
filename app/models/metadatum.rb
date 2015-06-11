class Metadatum < ActiveRecord::Base
  validates :mets, presence: true

  before_create :set_title
  before_update :set_title

  private
    def set_title
      xml_doc  = Nokogiri::XML(self.mets)
      self.title = xml_doc.xpath('(//mods:titleInfo/mods:title/text())[1]', 'mods' => 'http://www.loc.gov/mods/v3')
      self.title.blank? ? "untitled" : self.title
    end

end
