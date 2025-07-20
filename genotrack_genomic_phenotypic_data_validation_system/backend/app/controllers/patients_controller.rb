class PatientsController < ApplicationController
  before_action :set_patient, only: [:show, :update, :destroy]

  def index
    @patients = Patient.includes(:genome, :phenotypes)

    @patients = @patients.with_phenotype(params[:hpo_code]) if params[:hpo_code].present?
    @patients = @patients.with_gene(params[:gene_symbol]) if params[:gene_symbol].present?

    render json: {
      patients: @patients.map { |patient| patient_with_associations(patient) },
      total: @patients.count
    }
  end

  def show
    render json: patient_with_associations(@patient)
  end

  def create
    @patient = Patient.new(patient_params)

    if @patient.save
      render json: patient_with_associations(@patient), status: :created
    else
      render json: { errors: @patient.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @patient.update(patient_params)
      render json: patient_with_associations(@patient)
    else
      render json: { errors: @patient.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @patient.destroy
    head :no_content
  end

  private

  def set_patient
    @patient = Patient.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Paciente não encontrado' }, status: :not_found
  end

  def patient_params
    params.require(:patient).permit(:patient_id, :name, :birth_date, :gender)
  end

  def patient_with_associations(patient)
    {
      id: patient.id,
      patient_id: patient.patient_id,
      name: patient.name,
      birth_date: patient.birth_date,
      gender: patient.gender,
      age: patient.age,
      genome: patient.genome&.as_json(except: [:created_at, :updated_at]),
      phenotypes: patient.phenotypes.map { |p| phenotype_json(p) },
      gene_phenotype_association: patient.gene_phenotype_association
    }
  end

  def phenotype_json(phenotype)
    {
      id: phenotype.id,
      hpo_code: phenotype.hpo_code,
      hpo_term_name: phenotype.hpo_term_name,
      description: phenotype.description,
      severity: phenotype.severity,
      age_of_onset: phenotype.age_of_onset,
      is_severe: phenotype.is_severe?
    }
  end
end
