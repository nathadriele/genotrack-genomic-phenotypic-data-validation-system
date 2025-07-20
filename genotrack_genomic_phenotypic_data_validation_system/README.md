# GenoTrack - Genomic & Phenotypic Data Validation System

Sistema web para controle de informações genéticas e fenotípicas de pacientes em estudos nacionais de genômica.

## Funcionalidades Principais

- **Registro Seguro**: Dados genômicos e fenotípicos com validação automatizada
- **Consulta Rápida**: Interface otimizada para pesquisadores
- **Validação HPO**: Códigos fenotípicos seguindo padrão Human Phenotype Ontology
- **Integração Segura**: Comunicação entre bancos genético e fenotípico
- **Testes Rigorosos**: Cobertura ≥80% com testes unitários, API e E2E

## Caso de Uso Principal

**Cenário**: Pesquisadora Ana registra paciente BR-PACIENTE-0321
- **Gene**: LDLR (receptor de LDL)
- **Fenótipo**: HP:0003124 (hipercolesterolemia familiar)
- **Fluxo**: Cadastro → Validação → Visualização → Correção

## Stack Tecnológica

### Back-End
- **Ruby on Rails** - API RESTful
- **RSpec** - Testes unitários
- **PostgreSQL** - Banco de dados

### Front-End
- **HTML5/CSS3/JavaScript** - Interface científica
- **Cypress** - Testes E2E

### Testes e QA
- **Postman** - Testes de API
- **Robot Framework** - Testes BDD
- **SimpleCov** - Cobertura de código

## Estrutura do Projeto

```
genotrack/
├── backend/                 # API Ruby on Rails
│   ├── app/models/         # Patient, Genome, Phenotype
│   ├── spec/               # Testes RSpec
│   └── config/             # Configurações
├── frontend/               # Interface web
│   ├── src/                # Código fonte
│   └── cypress/            # Testes E2E
├── tests/
│   ├── postman/            # Coleções API
│   ├── robot/              # Testes BDD
│   └── reports/            # Relatórios HTML
└── docs/                   # Documentação
```

## Execução Rápida

```bash
# Backend
cd backend && bundle install && rails server

# Frontend
cd frontend && npm install && npm start

# Testes
bundle exec rspec                    # Unitários
npm run cypress:run                  # E2E
robot tests/robot/                   # BDD
```

## Validações Implementadas

- ✅ Código HPO formato HP:000XXXX
- ✅ Relacionamento obrigatório Patient ↔ Genome
- ✅ Múltiplos fenótipos por paciente
- ✅ Validação de genes conhecidos
- ✅ Integridade referencial

## Cobertura de Testes

- **Unitários**: Modelos e validações
- **API**: Endpoints CRUD e cenários de erro
- **E2E**: Fluxo completo de usuário
- **BDD**: Cenários comportamentais

## Métricas de Qualidade

- Cobertura de código ≥ 80%
- Tempo de resposta API < 200ms
- Interface responsiva
- Validação de dados em tempo real
