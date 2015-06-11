require 'test_helper'

class MetadatumTest < ActiveSupport::TestCase
  def setup
    @md = Metadatum.new(mets: "<mets/>", manifest: "{}")
  end

  test "should be valid" do
    assert @md.valid?
  end

  test "mets should be present" do
    @md.mets = ""
    assert_not @md.valid?
  end

  test "title should be set before save" do
    @md.mets = '<mods xmlns="http://www.loc.gov/mods/v3"><titleInfo><title>Manuscript journal</title></titleInfo></mods>'
    assert_equal(@md.send(:set_title), 'Manuscript journal')
  end

  test "objid should be set before save" do
    @md.mets = '<mets:mets xmlns:mets="http://www.loc.gov/METS/" OBJID="nz8060449"><mods xmlns="http://www.loc.gov/mods/v3"><titleInfo><title>Manuscript journal</title></titleInfo></mods></mets:mets>'
    assert_equal(@md.send(:set_objid), 'nz8060449')
  end

end
