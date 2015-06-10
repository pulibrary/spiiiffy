class Metadatum < ActiveRecord::Base
  validates :mets, presence: true
  
end
