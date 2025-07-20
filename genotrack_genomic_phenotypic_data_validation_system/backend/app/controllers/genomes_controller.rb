class GenomesController < ApplicationController
  before_action :set_patient
  before_action :set_genome, only: [:show, :update, :destroy]

  def show
    render json: genome_json(@genome)
  end

  def create
    @genome = @patient.build_genome(genome_params)

    if @genome.save
      render json: genome_json(@genome), status: :created
    else
      render json: { errors: @genome.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @genome.update(genome_params)
      render json: genome_json(@genome)
    else
      render json: { errors: @genome.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @genome.destroy
    head :no_content
  end

  private

  def set_patient
    @patient = Patient.find(params[:patient_id])
  end

  def set_genome
    @genome = @patient.genome
    unless @genome
      render json: { error: 'Genoma não encontrado para este paciente' }, status: :not_found
    end
  end

  def genome_params
    params.require(:genome).permit(
      :gene_symbol, :chromosome, :position, :reference_allele,
      :alternate_allele, :variant_type, :pathogenicity
    )
  end

  def genome_json(genome)
    {
      id: genome.id,
      patient_id: genome.patient_id,
      gene_symbol: genome.gene_symbol,
      chromosome: genome.chromosome,
      position: genome.position,
      reference_allele: genome.reference_allele,
      alternate_allele: genome.alternate_allele,
      variant_type: genome.variant_type,
      pathogenicity: genome.pathogenicity,
      variant_description: genome.variant_description,
      genomic_coordinates: genome.genomic_coordinates,
      is_pathogenic: genome.is_pathogenic?
    }
  end
end
