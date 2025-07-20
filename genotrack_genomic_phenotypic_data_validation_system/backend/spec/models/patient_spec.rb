require 'rails_helper'

RSpec.describe Patient, type: :model do
  describe 'associations' do
    it { should have_one(:genome).dependent(:destroy) }
    it { should have_many(:phenotypes).dependent(:destroy) }
  end

  describe 'validations' do
    context 'patient_id' do
      it { should validate_presence_of(:patient_id) }
      it { should validate_uniqueness_of(:patient_id) }

      it 'validates format BR-PACIENTE-XXXX' do
        valid_ids = ['BR-PACIENTE-0001', 'BR-PACIENTE-9999', 'BR-PACIENTE-0321']
        invalid_ids = ['BR-PACIENTE-001', 'PACIENTE-0001', 'BR-PACIENTE-ABCD', 'BR-PACIENTE-12345']

        valid_ids.each do |id|
          patient = build(:patient, patient_id: id)
          expect(patient).to be_valid, "#{id} should be valid"
        end

        invalid_ids.each do |id|
          patient = build(:patient, patient_id: id)
          expect(patient).not_to be_valid, "#{id} should be invalid"
          expect(patient.errors[:patient_id]).to include("deve seguir o formato BR-PACIENTE-XXXX")
        end
      end
    end

    context 'name' do
      it { should validate_presence_of(:name) }
      it { should validate_length_of(:name).is_at_least(2).is_at_most(100) }
    end

    context 'birth_date' do
      it { should validate_presence_of(:birth_date) }

      it 'rejects future dates' do
        patient = build(:patient, birth_date: 1.day.from_now)
        expect(patient).not_to be_valid
        expect(patient.errors[:birth_date]).to include("não pode ser no futuro")
      end

      it 'accepts past dates' do
        patient = build(:patient, birth_date: 30.years.ago)
        expect(patient).to be_valid
      end
    end

    context 'gender' do
      it { should validate_inclusion_of(:gender).in_array(%w[M F O]) }
    end
  end

  describe 'scopes' do
    let!(:patient1) { create(:patient) }
    let!(:patient2) { create(:patient, patient_id: 'BR-PACIENTE-0002') }
    let!(:phenotype1) { create(:phenotype, patient: patient1, hpo_code: 'HP:0003124') }
    let!(:genome1) { create(:genome, patient: patient1, gene_symbol: 'LDLR') }

    it '.with_phenotype returns patients with specific HPO code' do
      result = Patient.with_phenotype('HP:0003124')
      expect(result).to include(patient1)
      expect(result).not_to include(patient2)
    end

    it '.with_gene returns patients with specific gene' do
      result = Patient.with_gene('LDLR')
      expect(result).to include(patient1)
      expect(result).not_to include(patient2)
    end
  end

  describe 'instance methods' do
    let(:patient) { create(:patient, birth_date: 30.years.ago) }

    describe '#age' do
      it 'calculates age correctly' do
        expect(patient.age).to eq(30)
      end

      it 'returns nil when birth_date is nil' do
        patient.birth_date = nil
        expect(patient.age).to be_nil
      end
    end

    describe '#phenotype_codes' do
      it 'returns array of HPO codes' do
        create(:phenotype, patient: patient, hpo_code: 'HP:0003124')
        create(:phenotype, patient: patient, hpo_code: 'HP:0001677')

        expect(patient.phenotype_codes).to contain_exactly('HP:0003124', 'HP:0001677')
      end
    end

    describe '#gene_phenotype_association' do
      it 'returns association when genome exists' do
        genome = create(:genome, patient: patient, gene_symbol: 'LDLR')
        create(:phenotype, patient: patient, hpo_code: 'HP:0003124')

        association = patient.gene_phenotype_association
        expect(association[:gene]).to eq('LDLR')
        expect(association[:phenotypes]).to include('HP:0003124')
        expect(association[:variant]).to be_present
      end

      it 'returns nil when no genome' do
        expect(patient.gene_phenotype_association).to be_nil
      end
    end
  end
end
