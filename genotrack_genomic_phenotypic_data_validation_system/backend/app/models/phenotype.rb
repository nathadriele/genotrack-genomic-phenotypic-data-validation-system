class Phenotype < ApplicationRecord
  belongs_to :patient

  HPO_TERMS = {
    'HP:0003124' => 'Hipercolesterolemia',
    'HP:0001677' => 'Defeito do septo coronário',
    'HP:0000822' => 'Hipertensão',
    'HP:0002664' => 'Neoplasia',
    'HP:0001250' => 'Convulsões',
    'HP:0001263' => 'Atraso no desenvolvimento global',
    'HP:0000717' => 'Autismo',
    'HP:0001249' => 'Deficiência intelectual',
    'HP:0000365' => 'Perda auditiva',
    'HP:0000505' => 'Deficiência visual',
    'HP:0001508' => 'Falha no crescimento',
    'HP:0002664' => 'Neoplasia maligna',
    'HP:0000924' => 'Anormalidade do sistema esquelético'
  }.freeze

  validates :hpo_code, presence: true
  validates :hpo_code, format: {
    with: /\AHP:\d{7}\z/,
    message: "deve seguir o formato HP:0000000"
  }
  validates :hpo_code, inclusion: {
    in: HPO_TERMS.keys,
    message: "deve ser um código HPO válido no sistema"
  }

  validates :description, presence: true, length: { minimum: 5, maximum: 500 }
  validates :severity, inclusion: {
    in: %w[mild moderate severe profound],
    message: "deve ser mild, moderate, severe ou profound"
  }
  validates :age_of_onset, inclusion: {
    in: %w[congenital neonatal infantile childhood juvenile adult],
    allow_blank: true
  }

  validate :hpo_description_consistency
  validate :unique_hpo_per_patient

  scope :by_severity, ->(severity) { where(severity: severity) }
  scope :severe_phenotypes, -> { where(severity: %w[severe profound]) }
  scope :by_onset, ->(onset) { where(age_of_onset: onset) }

  def hpo_term_name
    HPO_TERMS[hpo_code]
  end

  def is_severe?
    %w[severe profound].include?(severity)
  end

  def full_description
    "#{hpo_code} - #{hpo_term_name}: #{description}"
  end

  private

  def hpo_description_consistency
    return unless hpo_code && HPO_TERMS[hpo_code]
    expected_term = HPO_TERMS[hpo_code].downcase
    return unless description

    unless description.downcase.include?(expected_term.split.first.downcase)
      errors.add(:description, "deve ser consistente com o termo HPO #{hpo_term_name}")
    end
  end

  def unique_hpo_per_patient
    return unless patient_id && hpo_code

    existing = Phenotype.where(patient_id: patient_id, hpo_code: hpo_code)
    existing = existing.where.not(id: id) if persisted?

    if existing.exists?
      errors.add(:hpo_code, "já existe para este paciente")
    end
  end
end
