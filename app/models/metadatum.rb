require 'iiif/presentation'

class Metadatum < ActiveRecord::Base
  validates :mets, presence: true
  validates_uniqueness_of :objid

  before_create :set_attributes, :make_manifest
  before_update :set_attributes, :make_manifest

  def to_param
    objid
  end

  #validates_format_of :objid, :with => /\A[a-z].+\z/
  def self.find(input)
    input.to_i == 0 ? find_by_objid(input) : super
  end

  private
    def set_attributes
      mets_doc  = Nokogiri::XML(self.mets)
      self.title = mets_doc.xpath('(//mods:titleInfo/mods:title/text())[1]', 'mods' => 'http://www.loc.gov/mods/v3')
      self.title.blank? ? "untitled" : self.title
      self.objid = mets_doc.xpath('string(//mets:mets/@OBJID)', 'mets' => 'http://www.loc.gov/METS/')
      self.abstract = mets_doc.xpath('(//mods:abstract/text())[1]', 'mods' => 'http://www.loc.gov/mods/v3')
      
      thumb_id = mets_doc.xpath('//mets:fileSec/mets:fileGrp[@USE="thumbnail"]/mets:file/mets:FLocat/@xlink:href', 'mets' => 'http://www.loc.gov/METS/', 'xlink' => 'http://www.w3.org/1999/xlink').to_s.sub(/^urn:pudl:images:deliverable:/,'')
      self.thumbnail = "http://libimages.princeton.edu/loris2/#{thumb_id}/full/242,/0/default.jpg"

    end

  private
    def make_manifest
      oid = "http://localhost:3000/metadata/#{self.objid}"
      seed = {
        '@id' => oid,
        'label' => self.title,
        'attribution' => "Provided by Princeton University"
      }
      # Any options you add are added to the object
      m = IIIF::Presentation::Manifest.new(seed)

      # make a sequence
      sequence = IIIF::Presentation::Sequence.new()
      sequence['@id'] = "#{m['@id']}/seq/"
      m.sequences << sequence

      mets_doc  = Nokogiri::XML(self.mets)

      #get fileSec
      files = mets_doc.xpath('//mets:fileSec/mets:fileGrp[@USE="deliverables"]/mets:file', 'mets' => 'http://www.loc.gov/METS/', 'xlink' => 'http://www.w3.org/1999/xlink')

      files_hash = Hash.new

      files.each do |file|
        fid = file.xpath('string(@ID)', 'mets' => 'http://www.loc.gov/METS/', 'xlink' => 'http://www.w3.org/1999/xlink')
        fadmid = file.xpath('string(@ADMID)', 'mets' => 'http://www.loc.gov/METS/', 'xlink' => 'http://www.w3.org/1999/xlink')
        files_hash[fid] = fadmid
      end

      #get structMap ... start with ordered list
      ol = mets_doc.xpath('//mets:structMap/mets:div/mets:div[@TYPE="OrderedList"]/mets:div', 'mets' => 'http://www.loc.gov/METS/')

      # I am having namespacing issues, so removing them for now... fix this later
      slop = mets_doc.clone
      slop.remove_namespaces!

      ol.each do |item|
        label = item.xpath('string(@LABEL)', 'mets' => 'http://www.loc.gov/METS/')
        order = item.xpath('string(@ORDER)', 'mets' => 'http://www.loc.gov/METS/')
        item_id = item.xpath('string(mets:fptr/@FILEID)', 'mets' => 'http://www.loc.gov/METS/')
        #the techmd uses the ADMID so we need to dedupe this
        item_aid = files_hash[item_id]

        iw = '//techMD[@ID="' + item_aid + '"]//imageWidth/text()'
        ih = '//techMD[@ID="' + item_aid + '"]//imageHeight/text()'
        i_urn = '//mets:file[@ADMID="' + item_aid +'"]/mets:FLocat/@xlink:href'

        img_width = slop.xpath(iw, 'mets' => 'http://www.loc.gov/METS/').to_s

        img_height = slop.xpath(ih, 'mets' => 'http://www.loc.gov/METS/').to_s
        img_id = mets_doc.xpath(i_urn, 'mets' => 'http://www.loc.gov/METS/', 'xlink' => 'http://www.w3.org/1999/xlink').to_s.sub(/^urn:pudl:images:deliverable:/,'')

        canvas = IIIF::Presentation::Canvas.new()

        canvas['@id'] = "#{m['@id']}/canvas/#{order}"

        canvas.width = img_width.to_i
        canvas.height = img_height.to_i
        canvas.label = label

        service = IIIF::Presentation::Resource.new('@context' => 'http://iiif.io/api/image/2/context.json', 'profile' => 'http://iiif.io/api/image/2/level2.json', '@id' => "http://libimages.princeton.edu/loris2/#{img_id}")

        image = IIIF::Presentation::ImageResource.new()

        image['@id'] = "http://libimages.princeton.edu/loris2/#{img_id}/full/#{img_width},#{img_height}/0/default.jpg"
        image.format = "image/jpeg"
        image.width = canvas.width
        image.height = canvas.height
        image.service = service

        images = IIIF::Presentation::Resource.new('@type' => 'oa:Annotation', 'motivation' => 'sc:painting', '@id' => "#{canvas['@id']}/images", 'resource' => image)

        canvas.images << images

        m.sequences.first.canvases << canvas
        #puts m.to_json(pretty:true)
        self.manifest = m.to_json(pretty:false)
      end

    end


end
