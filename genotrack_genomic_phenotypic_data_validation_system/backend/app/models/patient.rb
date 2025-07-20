class Patient < ApplicationRecord
  has_one :genome, dependent: :destroy
  has_many :phenotypes, dependent: :destroy

  validates :patient_id, presence: true, uniqueness: true
  validates :patient_id, format: {
    with: /\ABR-PACIENTE-\d{4}\z/,
    message: "deve seguir o formato BR-PACIENTE-XXXX"
  }

  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :birth_date, presence: true
  validates :gender, inclusion: { in: %w[M F O], message: "deve ser M, F ou O" }

  validate :birth_date_not_future
  validate :must_have_genome

  scope :with_phenotype, ->(hpo_code) { joins(:phenotypes).where(phenotypes: { hpo_code: hpo_code }) }
  scope :with_gene, ->(gene_symbol) { joins(:genome).where(genomes: { gene_symbol: gene_symbol }) }

  def age
    return nil unless birth_date
    ((Date.current - birth_date) / 365.25).floor
  end

  def phenotype_codes
    phenotypes.pluck(:hpo_code)
  end

  def gene_phenotype_association
    return nil unless genome
    {
      gene: genome.gene_symbol,
      phenotypes: phenotype_codes,
      variant: genome.variant_description
    }
  end

  private

  def birth_date_not_future
    return unless birth_date
    errors.add(:birth_date, "não pode ser no futuro") if birth_date > Date.current
  end

  def must_have_genome
    errors.add(:genome, "é obrigatório") if genome.nil? && persisted?
  end
end
