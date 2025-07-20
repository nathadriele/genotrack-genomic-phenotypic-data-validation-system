class Genome < ApplicationRecord
  belongs_to :patient

  KNOWN_GENES = %w[
    LDLR APOB PCSK9 LDLRAP1 ABCG5 ABCG8 CYP7A1 LIPA
    BRCA1 BRCA2 TP53 PTEN MLH1 MSH2 MSH6 PMS2
    CFTR HTT DMD FMR1 SMN1 MECP2 CDKL5 SCN1A
  ].freeze

  validates :gene_symbol, presence: true
  validates :gene_symbol, inclusion: {
    in: KNOWN_GENES,
    message: "deve ser um gene conhecido no sistema"
  }

  validates :chromosome, presence: true
  validates :chromosome, format: {
    with: /\A(chr)?(1[0-9]|2[0-2]|[1-9]|X|Y|MT)\z/i,
    message: "deve ser um cromossomo válido (1-22, X, Y, MT)"
  }

  validates :position, presence: true, numericality: { greater_than: 0 }
  validates :reference_allele, presence: true, format: { with: /\A[ATCG]+\z/i }
  validates :alternate_allele, presence: true, format: { with: /\A[ATCG]+\z/i }
  validates :variant_type, inclusion: { in: %w[SNV INDEL CNV SV] }
  validates :pathogenicity, inclusion: { in: %w[pathogenic likely_pathogenic uncertain benign likely_benign] }

  validate :reference_alternate_different
  validate :gene_chromosome_consistency

  scope :pathogenic_variants, -> { where(pathogenicity: %w[pathogenic likely_pathogenic]) }
  scope :by_gene, ->(gene) { where(gene_symbol: gene) }
  scope :by_chromosome, ->(chr) { where(chromosome: chr) }

  def variant_description
    "#{gene_symbol}:#{reference_allele}>#{alternate_allele} (#{variant_type})"
  end

  def is_pathogenic?
    %w[pathogenic likely_pathogenic].include?(pathogenicity)
  end

  def genomic_coordinates
    "#{chromosome}:#{position}"
  end

  private

  def reference_alternate_different
    return unless reference_allele && alternate_allele
    if reference_allele.upcase == alternate_allele.upcase
      errors.add(:alternate_allele, "deve ser diferente do alelo de referência")
    end
  end

  def gene_chromosome_consistency
    gene_chromosomes = {
      'LDLR' => '19', 'APOB' => '2', 'PCSK9' => '1', 'BRCA1' => '17', 'BRCA2' => '13',
      'TP53' => '17', 'CFTR' => '7', 'HTT' => '4', 'DMD' => 'X', 'FMR1' => 'X'
    }

    expected_chr = gene_chromosomes[gene_symbol]
    return unless expected_chr && chromosome

    normalized_chr = chromosome.gsub(/^chr/i, '')
    unless normalized_chr == expected_chr
      errors.add(:chromosome, "inconsistente com o gene #{gene_symbol} (esperado: #{expected_chr})")
    end
  end
end
