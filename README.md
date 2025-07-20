## 🧬 GenoTrack - Genomic & Phenotypic Data Validation System 

GenoTrack é um sistema teste para controle, validação e visualização de dados genéticos e fenotípicos de pacientes, voltado para estudos de genômica.

### Funcionalidades Principais

- Registro Seguro: Captura de dados genômicos e fenotípicos com múltiplas validações automáticas.
- Consulta Eficiente: Busca por gene, ID e fenótipo com navegação intuitiva.
- Validação HPO: Compatível com a Human Phenotype Ontology (HPO).
- Integração Genótipo-Fenótipo: Checagem cruzada de genes, cromossomos e fenótipos.
- Testes Automatizados: Cobertura de testes ≥80% com validação em tempo real.

### Caso de Uso Destacado

```
Paciente: BR-PACIENTE-0321
Pesquisadora: Ana Silva
Gene: LDLR (localizado no cromossomo 19)
Fenótipo: HP:0003124 (hipercolesterolemia familiar)
Fluxo Validado:
Cadastro → Validação de Código → Gene ↔ Cromossomo ↔ Fenótipo → Visualização
```

<img width="1309" height="811" alt="Caso de estudo BR-PACIENTE-0321 com gene LDLR e fenotipo HP0003124" src="https://github.com/user-attachments/assets/66288fa5-7e29-41bd-a0d2-c54e85deeb21" />

### Stack Tecnológica

### Backend
```
Ruby on Rails – API REST
RSpec – Testes unitários
PostgreSQL – Banco de dados
```

### Frontend
```
HTML5 / CSS3 / JavaScript – Interface responsiva
Cypress – Testes ponta a ponta (E2E)
```

### Qualidade e Testes
```
Postman/Newman – Testes de API
Robot Framework – Testes BDD
SimpleCov – Cobertura de código
```

#### Execução Rápida

```
# Backend
cd backend && bundle install && rails server

# Frontend
cd frontend && npm install && npm start

# Testes
bundle exec rspec                    # Testes unitários
npm run cypress:run                  # Testes E2E
robot tests/robot/                   # Testes BDD
```

### Validações Implementadas

- Código HPO com formato HP:000XXXX
- Paciente deve ter ao menos um gene e um fenótipo
- Consistência gene ↔ cromossomo
- Prevenção de duplicidade de fenótipos
- Várias regras de tipagem e integridade relacional

### Cobertura e Métricas de Teste
- Testes BDD – Robot Framework
- Testes de API – Newman/Postman
- Testes End-to-End – Cypress
- Testes Unitários – RSpec

### Testes RSpec

<img width="937" height="632" alt="EXECUTANDO TESTES UNITÁRIOS (RSpec)" src="https://github.com/user-attachments/assets/050761d5-06c1-46d0-b3ad-2ff5c92bd0f1" />

### Testes API NewmanPostman

<img width="618" height="772" alt="EXECUTANDO TESTES DE API NewmanPostman" src="https://github.com/user-attachments/assets/493e023e-8ce8-42a2-9eda-c9efcbe2b208" />

### Testes BDD Robot Framework

<img width="722" height="798" alt="EXECUTANDO TESTES BDD Robot Framework" src="https://github.com/user-attachments/assets/d8252178-a227-4679-a627-5c80d995d681" />

### Testes E2E Cypress

<img width="1330" height="462" alt="EXECUTANDO TESTES E2E Cypress" src="https://github.com/user-attachments/assets/e55f7bd9-d6c0-49c1-95b5-fbfbc3bc8130" />
