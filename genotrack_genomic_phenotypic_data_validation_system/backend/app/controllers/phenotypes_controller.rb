class PhenotypesController < ApplicationController
  before_action :set_patient
  before_action :set_phenotype, only: [:show, :update, :destroy]

  def index
    @phenotypes = @patient.phenotypes
    render json: {
      phenotypes: @phenotypes.map { |p| phenotype_json(p) },
      total: @phenotypes.count
    }
  end

  def show
    render json: phenotype_json(@phenotype)
  end

  def create
    @phenotype = @patient.phenotypes.build(phenotype_params)

    if @phenotype.save
      render json: phenotype_json(@phenotype), status: :created
    else
      render json: { errors: @phenotype.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @phenotype.update(phenotype_params)
      render json: phenotype_json(@phenotype)
    else
      render json: { errors: @phenotype.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @phenotype.destroy
    head :no_content
  end

  private

  def set_patient
    @patient = Patient.find(params[:patient_id])
  end

  def set_phenotype
    @phenotype = @patient.phenotypes.find(params[:id])
  end

  def phenotype_params
    params.require(:phenotype).permit(:hpo_code, :description, :severity, :age_of_onset)
  end

  def phenotype_json(phenotype)
    {
      id: phenotype.id,
      patient_id: phenotype.patient_id,
      hpo_code: phenotype.hpo_code,
      hpo_term_name: phenotype.hpo_term_name,
      description: phenotype.description,
      severity: phenotype.severity,
      age_of_onset: phenotype.age_of_onset,
      is_severe: phenotype.is_severe?,
      full_description: phenotype.full_description
    }
  end
end
