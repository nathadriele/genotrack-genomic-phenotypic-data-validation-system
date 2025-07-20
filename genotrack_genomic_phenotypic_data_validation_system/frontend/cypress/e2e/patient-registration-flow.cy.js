describe('GenoTrack - Patient Registration Flow', () => {
  const testPatient = {
    patient_id: 'BR-PACIENTE-0321',
    name: 'Ana Silva',
    birth_date: '1978-05-15',
    gender: 'F'
  }

  const testGenome = {
    gene_symbol: 'LDLR',
    chromosome: '19',
    position: 11200138,
    variant_type: 'SNV',
    reference_allele: 'C',
    alternate_allele: 'T',
    pathogenicity: 'pathogenic'
  }

  const testPhenotype = {
    hpo_code: 'HP:0003124',
    severity: 'moderate',
    age_of_onset: 'adult',
    description: 'Paciente apresenta hipercolesterolemia familiar hereditária com níveis elevados de LDL'
  }

  beforeEach(() => {
    cy.loginAsResearcher('Ana Silva')
  })

  it('should display the main interface correctly', () => {
    cy.get('.header h1').should('contain', 'GenoTrack')
    cy.get('.header p').should('contain', 'Sistema de Validação de Dados Genômicos e Fenotípicos')
    cy.get('.user-info span').should('contain', 'Pesquisadora: Ana Silva')

    // Check navigation tabs
    cy.get('.tab-btn').should('have.length', 3)
    cy.get('[data-tab="register"]').should('have.class', 'active')
    cy.get('[data-tab="search"]').should('be.visible')
    cy.get('[data-tab="associations"]').should('be.visible')
  })

  it('should validate patient ID format', () => {
    // Test invalid format
    cy.get('#patient-id').type('INVALID-FORMAT')
    cy.get('#patient-name').type('Test Patient')
    cy.get('#birth-date').type('1980-01-01')
    cy.get('#gender').select('M')

    cy.get('button[type="submit"]').click()

    // Should show validation error
    cy.get('#patient-id:invalid').should('exist')
  })

  it('should validate HPO code format', () => {
    cy.fillPatientInfo(testPatient)
    cy.fillGenomeInfo(testGenome)

    // HPO codes should follow HP:0000000 format
    cy.get('#hpo-code option').each(($option) => {
      const value = $option.val()
      if (value) {
        expect(value).to.match(/^HP:\d{7}$/)
      }
    })
  })

  it('should register patient BR-PACIENTE-0321 with LDLR gene and HP:0003124 phenotype', () => {
    // Fill patient information
    cy.fillPatientInfo(testPatient)

    // Fill genome information
    cy.fillGenomeInfo(testGenome)

    // Fill phenotype information
    cy.fillPhenotypeInfo(testPhenotype)

    // Submit form
    cy.get('button[type="submit"]').click()

    // Wait for API calls
    cy.wait('@createPatient')
    cy.wait('@createGenome')
    cy.wait('@createPhenotype')

    // Verify success notification
    cy.verifyNotification('success', 'Paciente registrado com sucesso')
  })

  it('should display gene-phenotype association correctly', () => {
    // Register patient first
    cy.registerPatient(testPatient, testGenome, testPhenotype)

    // Navigate to search tab
    cy.get('[data-tab="search"]').click()

    // Search for the patient
    cy.searchPatient({ patient_id: 'BR-PACIENTE-0321' })

    cy.wait('@searchPatients')

    // Verify patient appears in results
    cy.get('.patient-card').should('contain', 'BR-PACIENTE-0321')
    cy.get('.patient-card').should('contain', 'Ana Silva')

    // Verify gene-phenotype association
    cy.verifyGenePhentypeAssociation('LDLR', 'HP:0003124')
  })

  it('should edit phenotype successfully', () => {
    // Register patient first
    cy.registerPatient(testPatient, testGenome, testPhenotype)

    // Navigate to search and find patient
    cy.searchPatient({ patient_id: 'BR-PACIENTE-0321' })

    // Edit phenotype
    cy.editPhenotype({
      severity: 'severe',
      description: 'Hipercolesterolemia familiar severa com manifestações cardiovasculares precoces'
    })

    cy.wait('@updatePhenotype')

    // Verify update notification
    cy.verifyNotification('success', 'Fenótipo atualizado com sucesso')

    // Verify severity badge updated
    cy.get('.severity-badge').should('have.class', 'severity-severe')
  })

  it('should validate gene-chromosome consistency', () => {
    cy.fillPatientInfo(testPatient)

    // Select LDLR gene
    cy.get('#gene-symbol').select('LDLR')

    // Try to enter wrong chromosome
    cy.get('#chromosome').type('1')
    cy.get('#position').type('11200138')
    cy.get('#variant-type').select('SNV')
    cy.get('#reference-allele').type('C')
    cy.get('#alternate-allele').type('T')
    cy.get('#pathogenicity').select('pathogenic')

    cy.fillPhenotypeInfo(testPhenotype)

    cy.get('button[type="submit"]').click()

    // Should show validation error for chromosome inconsistency
    cy.verifyNotification('error', 'inconsistente com o gene LDLR')
  })

  it('should navigate between tabs correctly', () => {
    // Test tab navigation
    cy.get('[data-tab="search"]').click()
    cy.get('#search-tab').should('have.class', 'active')
    cy.get('#register-tab').should('not.have.class', 'active')

    cy.get('[data-tab="associations"]').click()
    cy.get('#associations-tab').should('have.class', 'active')
    cy.get('#search-tab').should('not.have.class', 'active')

    cy.get('[data-tab="register"]').click()
    cy.get('#register-tab').should('have.class', 'active')
    cy.get('#associations-tab').should('not.have.class', 'active')
  })
})
