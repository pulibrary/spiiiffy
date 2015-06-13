require 'iiif/presentation'

class Metadatum < ActiveRecord::Base
  validates :mets, presence: true
  validates_uniqueness_of :objid

  before_create :set_title, :set_objid, :make_manifest
  before_update :set_title, :set_objid, :make_manifest

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

  private
    def make_manifest
      oid = "http://localhost:3000/metadata/#{self.objid}"
      seed = {
        '@id' => oid,
        'label' => self.title
      }
      # Any options you add are added to the object
      m = IIIF::Presentation::Manifest.new(seed)

      xml_doc  = Nokogiri::XML(self.mets)

      #get fileSec
      files = xml_doc.xpath('//mets:fileSec/mets:fileGrp[@USE="deliverables"]/mets:file', 'mets' => 'http://www.loc.gov/METS/', 'xlink' => 'http://www.w3.org/1999/xlink')

      files_hash = Hash.new

      files.each do |file|
        fid = file.xpath('string(@ID)', 'mets' => 'http://www.loc.gov/METS/', 'xlink' => 'http://www.w3.org/1999/xlink')
        fadmid = file.xpath('string(@ADMID)', 'mets' => 'http://www.loc.gov/METS/', 'xlink' => 'http://www.w3.org/1999/xlink')
        files_hash[fid] = fadmid

        #flink = file.xpath('string(//mets:FLocat/@xlink:href)', 'mets' => 'http://www.loc.gov/METS/', 'xlink' => 'http://www.w3.org/1999/xlink')
        #files_hash[fid] = flink
      end

      #get structMap ... start with ordered list
      ol = xml_doc.xpath('//mets:structMap/mets:div/mets:div[@TYPE="OrderedList"]/mets:div', 'mets' => 'http://www.loc.gov/METS/')

      # I am having namespacing issues, so removing them for now... fix this later
      slop = xml_doc.clone
      slop.remove_namespaces!

      ol.each do |item|
        label = item.xpath('string(@LABEL)', 'mets' => 'http://www.loc.gov/METS/')
        order = item.xpath('string(@ORDER)', 'mets' => 'http://www.loc.gov/METS/')
        item_id = item.xpath('string(mets:fptr/@FILEID)', 'mets' => 'http://www.loc.gov/METS/')
        #the techmd uses the ADMID so we need to dedupe this
        item_aid = files_hash[item_id]

        iw = '//techMD[@ID="' + item_aid + '"]//imageWidth/text()'
        ih = '//techMD[@ID="' + item_aid + '"]//imageHeight/text()'

        #//techMD[@ID="yy12"]//imageWidth/text()
        img_width = slop.xpath(iw, 'mets' => 'http://www.loc.gov/METS/').to_s
        #img_width = slop.xpath('//techMD[@ID="wopp"]//imageWidth/text()', 'mets' => 'http://www.loc.gov/METS/').to_s
        img_height = slop.xpath(ih, 'mets' => 'http://www.loc.gov/METS/').to_s

        canvas = IIIF::Presentation::Canvas.new()

        canvas['@id'] = "#{m['@id']}/canvas/#{order}"

        # ...but there are also accessors and mutators for the properties mentioned in
        # the spec
        # test for positive integer for width and height

        canvas.width = img_width.to_i
        canvas.height = img_height.to_i
        canvas.label = label

        #images = IIIF::Presentation::Resource.new('@type' => 'oa:Annotation')
        #canvas.images << images

        m.sequences << canvas
        self.manifest = m.to_json(pretty: false)
      end

    end


end
