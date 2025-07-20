// Import commands.js using ES2015 syntax:
import './commands'

// Alternatively you can use CommonJS syntax:
// require('./commands')

// Configure Cypress behavior
Cypress.on('uncaught:exception', (err, runnable) => {
  // returning false here prevents Cypress from failing the test
  return false
})

// Global before hook
beforeEach(() => {
  // Setup API intercepts for all tests
  cy.setupApiIntercepts()

  // Clear local storage and cookies
  cy.clearLocalStorage()
  cy.clearCookies()
})
