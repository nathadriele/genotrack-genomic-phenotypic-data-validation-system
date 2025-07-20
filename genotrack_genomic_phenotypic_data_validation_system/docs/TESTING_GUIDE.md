# GenoTrack - Guia de Testes

## Visão Geral

Este documento descreve a estratégia completa de testes implementada no sistema GenoTrack, um sistema de validação de dados genômicos e fenotípicos desenvolvido com foco em qualidade e confiabilidade.

## Tipos de Testes Implementados

### 1. Testes Unitários (RSpec)
**Localização**: `backend/spec/`
**Framework**: RSpec + FactoryBot + Shoulda Matchers

#### Cobertura:
- ✅ Validação de modelos (Patient, Genome, Phenotype)
- ✅ Relacionamentos entre entidades
- ✅ Validação de códigos HPO (formato HP:000XXXX)
- ✅ Consistência gene-cromossomo
- ✅ Regras de negócio específicas

#### Execução:
```bash
cd backend
bundle exec rspec
```

#### Relatórios:
- HTML: `tests/reports/rspec_report.html`
- Cobertura: SimpleCov integrado

### 2. Testes de API (Postman/Newman)
**Localização**: `tests/postman/`
**Framework**: Postman Collections + Newman

#### Cobertura:
- ✅ Endpoints CRUD para pacientes
- ✅ Validação de schemas JSON
- ✅ Códigos de status HTTP
- ✅ Cenários de erro (HPO inválido, ID incorreto)
- ✅ Testes de integração entre endpoints

#### Execução:
```bash
newman run tests/postman/GenoTrack_API_Tests.postman_collection.json \
       -e tests/postman/GenoTrack_Environments.postman_environment.json
```

#### Casos de Teste Principais:
1. **Registro de Paciente BR-PACIENTE-0321**
2. **Criação de Genoma LDLR**
3. **Adição de Fenótipo HP:0003124**
4. **Validação de Erros**
5. **Atualização de Dados**

### 3. Testes E2E (Cypress)
**Localização**: `frontend/cypress/`
**Framework**: Cypress

#### Cobertura:
- ✅ Fluxo completo de registro de paciente
- ✅ Navegação entre abas da interface
- ✅ Validação de formulários
- ✅ Visualização de associações gene-fenótipo
- ✅ Edição de dados fenotípicos

#### Execução:
```bash
cd frontend
npm run cypress:run
```

#### Cenários Principais:
1. **Login da pesquisadora Ana**
2. **Registro completo do caso BR-PACIENTE-0321**
3. **Verificação de associação LDLR ↔ HP:0003124**
4. **Edição de severidade do fenótipo**

### 4. Testes BDD (Robot Framework)
**Localização**: `tests/robot/`
**Framework**: Robot Framework + SeleniumLibrary

#### Cobertura:
- ✅ Cenários em linguagem natural
- ✅ Testes de integração completa
- ✅ Validações comportamentais
- ✅ Simulação de fluxos reais de usuário

#### Execução:
```bash
robot tests/robot/genotrack_patient_registration.robot
```

#### Cenários BDD:
```gherkin
Cenário: Registro completo do paciente BR-PACIENTE-0321
    Dado que Ana acessa o sistema GenoPhen Tracker
    Quando ela registra o paciente BR-PACIENTE-0321 com o gene LDLR e fenótipo HP:0003124
    Então ela deve visualizar o vínculo entre o gene LDLR e a hipercolesterolemia familiar
```

## Execução Automatizada

### Script Completo
Execute todos os testes com um único comando:
```bash
./run_all_tests.sh
```

### Execução Individual
```bash
# Testes unitários
cd backend && bundle exec rspec

# Testes de API
newman run tests/postman/GenoTrack_API_Tests.postman_collection.json

# Testes E2E
cd frontend && npm run cypress:run

# Testes BDD
robot tests/robot/genotrack_patient_registration.robot
```

## Relatórios e Métricas

### Relatório Consolidado
Acesse: `tests/reports/index.html`

### Métricas de Qualidade
- **Cobertura de Código**: ≥ 80%
- **Tempo de Resposta API**: < 200ms
- **Taxa de Sucesso**: 100% nos testes críticos
- **Validação HPO**: 100% dos códigos validados

### Relatórios Individuais
- **RSpec**: `tests/reports/rspec_report.html`
- **Postman**: `tests/reports/postman_report.html`
- **Cypress**: `tests/reports/cypress_report.html`
- **Robot**: `tests/reports/robot_report.html`

## Validações Críticas

### 1. Formato de ID do Paciente
```regex
^BR-PACIENTE-\d{4}$
```
**Exemplos válidos**: BR-PACIENTE-0321, BR-PACIENTE-9999
**Exemplos inválidos**: PACIENTE-0001, BR-PACIENTE-001

### 2. Códigos HPO
```regex
^HP:\d{7}$
```
**Exemplos válidos**: HP:0003124, HP:0001677
**Exemplos inválidos**: HP:XYZ, HP:003124

### 3. Consistência Gene-Cromossomo
| Gene | Cromossomo Esperado |
|------|-------------------|
| LDLR | 19 |
| BRCA1 | 17 |
| BRCA2 | 13 |
| CFTR | 7 |

### 4. Alelos Válidos
- Apenas caracteres: A, T, C, G
- Alelo de referência ≠ alelo alternativo

## Caso de Estudo Principal

### Paciente BR-PACIENTE-0321
- **Nome**: Ana Silva
- **Gene**: LDLR (cromossomo 19)
- **Variante**: C>T (SNV, patogênica)
- **Fenótipo**: HP:0003124 (hipercolesterolemia familiar)
- **Severidade**: Moderada → Severa (após edição)

### Fluxo de Teste
1. ✅ Registro do paciente
2. ✅ Validação de dados genômicos
3. ✅ Associação gene-fenótipo
4. ✅ Visualização na interface
5. ✅ Edição de severidade
6. ✅ Consulta e busca

## Configuração do Ambiente

### Pré-requisitos
```bash
# Ruby e Rails
ruby 3.1.0
rails 7.0.0

# Node.js e npm
node >= 16.0.0
npm >= 8.0.0

# Python e Robot Framework
python >= 3.8
pip install robotframework robotframework-seleniumlibrary

# Newman (Postman CLI)
npm install -g newman
```

### Instalação
```bash
# Backend
cd backend
bundle install

# Frontend
cd frontend
npm install

# Cypress
npx cypress install
```

## Melhores Práticas

### 1. Nomenclatura de Testes
- **Unitários**: `describe 'Model' do ... it 'should validate ...' do`
- **API**: `Test Case: Create Patient BR-PACIENTE-0321`
- **E2E**: `it('should register patient with LDLR gene')`
- **BDD**: `Cenário: Registro completo do paciente`

### 2. Dados de Teste
- Use factories para dados consistentes
- IDs seguem padrão BR-PACIENTE-XXXX
- HPO codes reais do sistema
- Genes conhecidos na base

### 3. Asserções
- Valide formato antes de conteúdo
- Teste cenários positivos e negativos
- Verifique persistência de dados
- Confirme notificações de usuário

## Troubleshooting

### Problemas Comuns
1. **Cypress não encontra elementos**: Aguarde carregamento com `cy.wait()`
2. **API retorna 500**: Verifique se backend está rodando
3. **Robot Framework falha**: Confirme se ChromeDriver está instalado
4. **RSpec falha**: Execute `bundle install` e `rails db:test:prepare`

### Logs e Debug
- **RSpec**: `--format documentation`
- **Cypress**: Screenshots automáticos em falhas
- **Robot**: Logs detalhados em `tests/reports/`
- **Newman**: Output verbose com `--verbose`

---

**Desenvolvido com foco em qualidade e validação rigorosa para sistemas de genômica médica.**
