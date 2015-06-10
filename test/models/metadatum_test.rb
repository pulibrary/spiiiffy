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

end
