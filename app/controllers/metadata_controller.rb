require 'iiif/presentation'
class MetadataController < ApplicationController
  before_action :set_metadatum, only: [:show, :edit, :update, :destroy]
  layout "mirador", only: :show
  # GET /metadata
  # GET /metadata.json
  def index
    @metadata = Metadatum.all
  end

  # GET /metadata/1
  # GET /metadata/1.json
  def show
    respond_to do |format|
      format.html { render :show }
      format.json {
        #m = IIIF::Service.parse(@metadatum.manifest)

        render :json => @metadatum.manifest
        #render :json => m.to_json(pretty: true)
      }

    end
  end

  # GET /metadata/new
  def new
    @metadatum = Metadatum.new
  end

  # GET /metadata/1/edit
  def edit
  end

  # POST /metadata
  # POST /metadata.json
  def create
    @metadatum = Metadatum.new(metadatum_params)

    respond_to do |format|
      if @metadatum.save
        format.html { redirect_to @metadatum, notice: 'Metadatum was successfully created.' }
        format.json { render :show, status: :created, location: @metadatum }
      else
        format.html { render :new }
        format.json { render json: @metadatum.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /metadata/1
  # PATCH/PUT /metadata/1.json
  def update
    respond_to do |format|
      if @metadatum.update(metadatum_params)
        format.html { redirect_to @metadatum, notice: 'Metadatum was successfully updated.' }
        format.json { render :show, status: :ok, location: @metadatum }
      else
        format.html { render :edit }
        format.json { render json: @metadatum.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /metadata/1
  # DELETE /metadata/1.json
  def destroy
    @metadatum.destroy
    respond_to do |format|
      format.html { redirect_to metadata_url, notice: 'Metadatum was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_metadatum
      @metadatum = Metadatum.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def metadatum_params
      params.require(:metadatum).permit(:mets, :manifest)
    end
end
