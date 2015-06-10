json.array!(@metadata) do |metadatum|
  json.extract! metadatum, :id, :mets, :manifest
  json.url metadatum_url(metadatum, format: :json)
end
