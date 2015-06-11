class Metadatum < ActiveRecord::Base
  validates :mets, presence: true
  validates_uniqueness_of :objid

  before_create :set_title, :set_objid
  before_update :set_title, :set_objid

  def to_param
    objid
  end

  #validates_format_of :objid, :with => /\A[a-z].+\z/
  def self.find(input)
    input.to_i == 0 ? find_by_objid(input) : super
  end

  private
    def set_title
      xml_doc  = Nokogiri::XML(self.mets)
      self.title = xml_doc.xpath('(//mods:titleInfo/mods:title/text())[1]', 'mods' => 'http://www.loc.gov/mods/v3')
      self.title.blank? ? "untitled" : self.title
      # xml_doc.xpath('(/mets:mets/@OBJID', 'mets' => 'http://www.loc.gov/METS/')
    end

  private
    def set_objid
      xml_doc  = Nokogiri::XML(self.mets)
      self.objid = xml_doc.xpath('string(//mets:mets/@OBJID)', 'mets' => 'http://www.loc.gov/METS/')
    end


end
