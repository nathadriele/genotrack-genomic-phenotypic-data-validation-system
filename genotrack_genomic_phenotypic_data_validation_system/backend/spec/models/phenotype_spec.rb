require 'rails_helper'

RSpec.describe Phenotype, type: :model do
  describe 'associations' do
    it { should belong_to(:patient) }
  end

  describe 'validations' do
    context 'hpo_code' do
      it { should validate_presence_of(:hpo_code) }

      it 'validates HPO format HP:0000000' do
        valid_codes = ['HP:0003124', 'HP:0001677', 'HP:0000822']
        invalid_codes = ['HP:XYZ', 'HP:003124', 'HP:00031240', 'H:0003124', 'HP0003124']

        valid_codes.each do |code|
          phenotype = build(:phenotype, hpo_code: code)
          expect(phenotype).to be_valid, "#{code} should be valid"
        end

        invalid_codes.each do |code|
          phenotype = build(:phenotype, hpo_code: code)
          expect(phenotype).not_to be_valid, "#{code} should be invalid"
          expect(phenotype.errors[:hpo_code]).to include("deve seguir o formato HP:0000000")
        end
      end

      it 'validates HPO code is in known terms' do
        phenotype = build(:phenotype, hpo_code: 'HP:9999999')
        expect(phenotype).not_to be_valid
        expect(phenotype.errors[:hpo_code]).to include("deve ser um código HPO válido no sistema")
      end

      it 'prevents duplicate HPO codes per patient' do
        patient = create(:patient)
        create(:phenotype, patient: patient, hpo_code: 'HP:0003124')

        duplicate = build(:phenotype, patient: patient, hpo_code: 'HP:0003124')
        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:hpo_code]).to include("já existe para este paciente")
      end
    end

    context 'description' do
      it { should validate_presence_of(:description) }
      it { should validate_length_of(:description).is_at_least(5).is_at_most(500) }

      it 'validates description consistency with HPO term' do
        phenotype = build(:phenotype,
          hpo_code: 'HP:0003124',
          description: 'Paciente apresenta diabetes'
        )
        expect(phenotype).not_to be_valid
        expect(phenotype.errors[:description]).to include("deve ser consistente com o termo HPO Hipercolesterolemia")
      end
    end

    context 'severity' do
      it { should validate_inclusion_of(:severity).in_array(%w[mild moderate severe profound]) }
    end

    context 'age_of_onset' do
      it 'allows valid onset values' do
        valid_onsets = %w[congenital neonatal infantile childhood juvenile adult]
        valid_onsets.each do |onset|
          phenotype = build(:phenotype, age_of_onset: onset)
          expect(phenotype).to be_valid
        end
      end

      it 'allows blank onset' do
        phenotype = build(:phenotype, age_of_onset: nil)
        expect(phenotype).to be_valid
      end
    end
  end

  describe 'scopes' do
    let!(:mild_phenotype) { create(:phenotype, severity: 'mild') }
    let!(:severe_phenotype) { create(:phenotype, severity: 'severe') }
    let!(:profound_phenotype) { create(:phenotype, severity: 'profound') }
    let!(:childhood_phenotype) { create(:phenotype, age_of_onset: 'childhood') }

    it '.by_severity filters by severity level' do
      result = Phenotype.by_severity('severe')
      expect(result).to include(severe_phenotype)
      expect(result).not_to include(mild_phenotype)
    end

    it '.severe_phenotypes returns severe and profound' do
      result = Phenotype.severe_phenotypes
      expect(result).to include(severe_phenotype, profound_phenotype)
      expect(result).not_to include(mild_phenotype)
    end

    it '.by_onset filters by age of onset' do
      result = Phenotype.by_onset('childhood')
      expect(result).to include(childhood_phenotype)
    end
  end

  describe 'instance methods' do
    let(:phenotype) { create(:phenotype, hpo_code: 'HP:0003124', severity: 'severe') }

    describe '#hpo_term_name' do
      it 'returns the correct HPO term name' do
        expect(phenotype.hpo_term_name).to eq('Hipercolesterolemia')
      end
    end

    describe '#is_severe?' do
      it 'returns true for severe phenotypes' do
        expect(phenotype.is_severe?).to be true
      end

      it 'returns false for mild phenotypes' do
        mild_phenotype = create(:phenotype, severity: 'mild')
        expect(mild_phenotype.is_severe?).to be false
      end
    end

    describe '#full_description' do
      it 'returns formatted description' do
        expected = "HP:0003124 - Hipercolesterolemia: #{phenotype.description}"
        expect(phenotype.full_description).to eq(expected)
      end
    end
  end

  describe 'case study: BR-PACIENTE-0321 with LDLR and HP:0003124' do
    let(:patient) { create(:patient, patient_id: 'BR-PACIENTE-0321') }
    let(:genome) { create(:genome, patient: patient, gene_symbol: 'LDLR') }

    it 'creates valid phenotype for hipercolesterolemia familiar' do
      phenotype = build(:phenotype,
        patient: patient,
        hpo_code: 'HP:0003124',
        description: 'Paciente apresenta hipercolesterolemia familiar hereditária',
        severity: 'moderate',
        age_of_onset: 'adult'
      )

      expect(phenotype).to be_valid
      expect(phenotype.hpo_term_name).to eq('Hipercolesterolemia')
    end
  end
end
