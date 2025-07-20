// Custom commands for GenoTrack E2E tests

// Command to simulate researcher login
Cypress.Commands.add('loginAsResearcher', (name = 'Ana Silva') => {
  cy.visit('/')
  cy.get('.user-info span').should('contain', name)
})

// Command to fill patient basic information
Cypress.Commands.add('fillPatientInfo', (patientData) => {
  cy.get('#patient-id').type(patientData.patient_id)
  cy.get('#patient-name').type(patientData.name)
  cy.get('#birth-date').type(patientData.birth_date)
  cy.get('#gender').select(patientData.gender)
})

// Command to fill genome information
Cypress.Commands.add('fillGenomeInfo', (genomeData) => {
  cy.get('#gene-symbol').select(genomeData.gene_symbol)
  cy.get('#chromosome').type(genomeData.chromosome)
  cy.get('#position').type(genomeData.position.toString())
  cy.get('#variant-type').select(genomeData.variant_type)
  cy.get('#reference-allele').type(genomeData.reference_allele)
  cy.get('#alternate-allele').type(genomeData.alternate_allele)
  cy.get('#pathogenicity').select(genomeData.pathogenicity)
})

// Command to fill phenotype information
Cypress.Commands.add('fillPhenotypeInfo', (phenotypeData) => {
  cy.get('#hpo-code').select(phenotypeData.hpo_code)
  cy.get('#severity').select(phenotypeData.severity)
  if (phenotypeData.age_of_onset) {
    cy.get('#age-of-onset').select(phenotypeData.age_of_onset)
  }
  cy.get('#phenotype-description').type(phenotypeData.description)
})

// Command to register complete patient
Cypress.Commands.add('registerPatient', (patientData, genomeData, phenotypeData) => {
  cy.fillPatientInfo(patientData)
  cy.fillGenomeInfo(genomeData)
  cy.fillPhenotypeInfo(phenotypeData)
  cy.get('button[type="submit"]').click()
})

// Command to verify gene-phenotype association
Cypress.Commands.add('verifyGenePhentypeAssociation', (gene, hpoCode) => {
  cy.get('.gene-phenotype-info').should('be.visible')
  cy.get('.gene-info').should('contain', gene)
  cy.get('.phenotype-info').should('contain', hpoCode)
})

// Command to search patient
Cypress.Commands.add('searchPatient', (searchCriteria) => {
  cy.get('[data-tab="search"]').click()

  if (searchCriteria.patient_id) {
    cy.get('#search-patient-id').type(searchCriteria.patient_id)
  }
  if (searchCriteria.gene) {
    cy.get('#search-gene').select(searchCriteria.gene)
  }
  if (searchCriteria.hpo_code) {
    cy.get('#search-hpo').select(searchCriteria.hpo_code)
  }

  cy.get('#search-btn').click()
})

// Command to edit phenotype
Cypress.Commands.add('editPhenotype', (newData) => {
  cy.get('.btn-edit-phenotype').first().click()
  cy.get('#edit-phenotype-modal').should('have.class', 'show')

  if (newData.severity) {
    cy.get('#edit-severity').select(newData.severity)
  }
  if (newData.description) {
    cy.get('#edit-description').clear().type(newData.description)
  }

  cy.get('#save-phenotype').click()
})

// Command to verify notification
Cypress.Commands.add('verifyNotification', (type, message) => {
  cy.get('.notifications .notification')
    .should('have.class', type)
    .and('contain', message)
})

// Command to setup API intercepts
Cypress.Commands.add('setupApiIntercepts', () => {
  cy.intercept('POST', '**/patients', { fixture: 'patient-created.json' }).as('createPatient')
  cy.intercept('GET', '**/patients/*', { fixture: 'patient-details.json' }).as('getPatient')
  cy.intercept('POST', '**/patients/*/genome', { fixture: 'genome-created.json' }).as('createGenome')
  cy.intercept('POST', '**/patients/*/phenotypes', { fixture: 'phenotype-created.json' }).as('createPhenotype')
  cy.intercept('PUT', '**/patients/*/phenotypes/*', { fixture: 'phenotype-updated.json' }).as('updatePhenotype')
  cy.intercept('GET', '**/patients?**', { fixture: 'patients-search.json' }).as('searchPatients')
})
