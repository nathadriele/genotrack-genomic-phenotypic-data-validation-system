FactoryBot.define do
  factory :patient do
    sequence(:patient_id) { |n| "BR-PACIENTE-#{n.to_s.rjust(4, '0')}" }
    name { "Paciente Teste #{patient_id}" }
    birth_date { 30.years.ago }
    gender { %w[M F O].sample }

    trait :with_genome do
      after(:create) do |patient|
        create(:genome, patient: patient)
      end
    end

    trait :with_phenotypes do
      after(:create) do |patient|
        create_list(:phenotype, 2, patient: patient)
      end
    end

    trait :case_study do
      patient_id { 'BR-PACIENTE-0321' }
      name { 'Ana Silva' }
      birth_date { 45.years.ago }
      gender { 'F' }
    end
  end

  factory :genome do
    association :patient
    gene_symbol { 'LDLR' }
    chromosome { '19' }
    position { 11200138 }
    reference_allele { 'C' }
    alternate_allele { 'T' }
    variant_type { 'SNV' }
    pathogenicity { 'pathogenic' }

    trait :brca1 do
      gene_symbol { 'BRCA1' }
      chromosome { '17' }
      position { 43094077 }
    end

    trait :benign do
      pathogenicity { 'benign' }
    end

    trait :uncertain do
      pathogenicity { 'uncertain' }
    end
  end

  factory :phenotype do
    association :patient
    hpo_code { 'HP:0003124' }
    description { 'Paciente apresenta hipercolesterolemia familiar hereditária' }
    severity { 'moderate' }
    age_of_onset { 'adult' }

    trait :severe do
      severity { 'severe' }
      description { 'Hipercolesterolemia severa com manifestações precoces' }
    end

    trait :childhood_onset do
      age_of_onset { 'childhood' }
      description { 'Hipercolesterolemia com início na infância' }
    end

    trait :cardiac_defect do
      hpo_code { 'HP:0001677' }
      description { 'Defeito do septo coronário identificado em exame' }
    end

    trait :hypertension do
      hpo_code { 'HP:0000822' }
      description { 'Hipertensão arterial sistêmica' }
    end
  end
end
