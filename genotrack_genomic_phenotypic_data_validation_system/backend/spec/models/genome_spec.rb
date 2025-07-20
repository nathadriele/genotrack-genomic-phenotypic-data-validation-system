require 'rails_helper'

RSpec.describe Genome, type: :model do
  describe 'associations' do
    it { should belong_to(:patient) }
  end

  describe 'validations' do
    context 'gene_symbol' do
      it { should validate_presence_of(:gene_symbol) }

      it 'validates gene is in known genes list' do
        valid_genes = %w[LDLR APOB PCSK9 BRCA1 BRCA2 CFTR]
        invalid_genes = %w[UNKNOWN FAKE GENE123]

        valid_genes.each do |gene|
          genome = build(:genome, gene_symbol: gene)
          expect(genome).to be_valid, "#{gene} should be valid"
        end

        invalid_genes.each do |gene|
          genome = build(:genome, gene_symbol: gene)
          expect(genome).not_to be_valid, "#{gene} should be invalid"
          expect(genome.errors[:gene_symbol]).to include("deve ser um gene conhecido no sistema")
        end
      end
    end

    context 'chromosome' do
      it { should validate_presence_of(:chromosome) }

      it 'validates chromosome format' do
        valid_chromosomes = %w[1 22 X Y MT chr1 chr22 chrX chrY chrMT]
        invalid_chromosomes = %w[23 0 Z chr23 chr0 chrZ chromosome1]

        valid_chromosomes.each do |chr|
          genome = build(:genome, chromosome: chr)
          expect(genome).to be_valid, "#{chr} should be valid"
        end

        invalid_chromosomes.each do |chr|
          genome = build(:genome, chromosome: chr)
          expect(genome).not_to be_valid, "#{chr} should be invalid"
          expect(genome.errors[:chromosome]).to include("deve ser um cromossomo válido (1-22, X, Y, MT)")
        end
      end
    end

    context 'position' do
      it { should validate_presence_of(:position) }
      it { should validate_numericality_of(:position).is_greater_than(0) }
    end

    context 'alleles' do
      it { should validate_presence_of(:reference_allele) }
      it { should validate_presence_of(:alternate_allele) }

      it 'validates alleles contain only ATCG' do
        valid_alleles = %w[A T C G AT CG ATCG]
        invalid_alleles = %w[N X ATCGN 123 atcg]

        valid_alleles.each do |allele|
          genome = build(:genome, reference_allele: allele, alternate_allele: 'T')
          expect(genome).to be_valid, "#{allele} should be valid"
        end

        invalid_alleles.each do |allele|
          genome = build(:genome, reference_allele: allele)
          expect(genome).not_to be_valid, "#{allele} should be invalid"
        end
      end

      it 'validates reference and alternate alleles are different' do
        genome = build(:genome, reference_allele: 'A', alternate_allele: 'A')
        expect(genome).not_to be_valid
        expect(genome.errors[:alternate_allele]).to include("deve ser diferente do alelo de referência")
      end
    end

    context 'variant_type' do
      it { should validate_inclusion_of(:variant_type).in_array(%w[SNV INDEL CNV SV]) }
    end

    context 'pathogenicity' do
      it { should validate_inclusion_of(:pathogenicity).in_array(%w[pathogenic likely_pathogenic uncertain benign likely_benign]) }
    end

    context 'gene-chromosome consistency' do
      it 'validates LDLR is on chromosome 19' do
        genome = build(:genome, gene_symbol: 'LDLR', chromosome: '19')
        expect(genome).to be_valid

        genome = build(:genome, gene_symbol: 'LDLR', chromosome: '1')
        expect(genome).not_to be_valid
        expect(genome.errors[:chromosome]).to include("inconsistente com o gene LDLR (esperado: 19)")
      end

      it 'validates BRCA1 is on chromosome 17' do
        genome = build(:genome, gene_symbol: 'BRCA1', chromosome: 'chr17')
        expect(genome).to be_valid

        genome = build(:genome, gene_symbol: 'BRCA1', chromosome: '1')
        expect(genome).not_to be_valid
        expect(genome.errors[:chromosome]).to include("inconsistente com o gene BRCA1 (esperado: 17)")
      end
    end
  end

  describe 'scopes' do
    let!(:pathogenic_genome) { create(:genome, pathogenicity: 'pathogenic') }
    let!(:benign_genome) { create(:genome, pathogenicity: 'benign') }
    let!(:ldlr_genome) { create(:genome, gene_symbol: 'LDLR') }
    let!(:brca1_genome) { create(:genome, gene_symbol: 'BRCA1') }

    it '.pathogenic_variants returns pathogenic and likely_pathogenic' do
      likely_pathogenic = create(:genome, pathogenicity: 'likely_pathogenic')
      result = Genome.pathogenic_variants
      expect(result).to include(pathogenic_genome, likely_pathogenic)
      expect(result).not_to include(benign_genome)
    end

    it '.by_gene filters by gene symbol' do
      result = Genome.by_gene('LDLR')
      expect(result).to include(ldlr_genome)
      expect(result).not_to include(brca1_genome)
    end

    it '.by_chromosome filters by chromosome' do
      chr19_genome = create(:genome, chromosome: '19')
      result = Genome.by_chromosome('19')
      expect(result).to include(chr19_genome)
    end
  end

  describe 'instance methods' do
    let(:genome) { create(:genome,
      gene_symbol: 'LDLR',
      reference_allele: 'C',
      alternate_allele: 'T',
      variant_type: 'SNV',
      pathogenicity: 'pathogenic',
      chromosome: '19',
      position: 11200138
    )}

    describe '#variant_description' do
      it 'returns formatted variant description' do
        expected = "LDLR:C>T (SNV)"
        expect(genome.variant_description).to eq(expected)
      end
    end

    describe '#is_pathogenic?' do
      it 'returns true for pathogenic variants' do
        expect(genome.is_pathogenic?).to be true
      end

      it 'returns false for benign variants' do
        benign_genome = create(:genome, pathogenicity: 'benign')
        expect(benign_genome.is_pathogenic?).to be false
      end
    end

    describe '#genomic_coordinates' do
      it 'returns chromosome:position format' do
        expect(genome.genomic_coordinates).to eq('19:11200138')
      end
    end
  end

  describe 'case study: BR-PACIENTE-0321 with LDLR variant' do
    let(:patient) { create(:patient, patient_id: 'BR-PACIENTE-0321') }

    it 'creates valid LDLR pathogenic variant' do
      genome = build(:genome,
        patient: patient,
        gene_symbol: 'LDLR',
        chromosome: '19',
        position: 11200138,
        reference_allele: 'C',
        alternate_allele: 'T',
        variant_type: 'SNV',
        pathogenicity: 'pathogenic'
      )

      expect(genome).to be_valid
      expect(genome.is_pathogenic?).to be true
      expect(genome.variant_description).to eq('LDLR:C>T (SNV)')
    end
  end
end
