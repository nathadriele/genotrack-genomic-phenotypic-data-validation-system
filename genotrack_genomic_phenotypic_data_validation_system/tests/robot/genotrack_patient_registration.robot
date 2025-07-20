*** Settings ***
Documentation    Testes BDD para o sistema GenoTrack - Registro e consulta de pacientes com dados genômicos e fenotípicos
Library          SeleniumLibrary
Library          RequestsLibrary
Library          Collections
Library          String
Resource         keywords/genotrack_keywords.robot
Resource         keywords/api_keywords.robot
Suite Setup      Setup Test Environment
Suite Teardown   Teardown Test Environment
Test Setup       Setup Test Case
Test Teardown    Teardown Test Case

*** Variables ***
${BROWSER}              chrome
${BASE_URL}             http://localhost:8080
${API_BASE_URL}         http://localhost:3000/api/v1
${RESEARCHER_NAME}      Ana Silva
${PATIENT_ID}           BR-PACIENTE-0321
${PATIENT_NAME}         Ana Silva
${BIRTH_DATE}           1978-05-15
${GENDER}               F
${GENE_SYMBOL}          LDLR
${CHROMOSOME}           19
${POSITION}             11200138
${REFERENCE_ALLELE}     C
${ALTERNATE_ALLELE}     T
${VARIANT_TYPE}         SNV
${PATHOGENICITY}        pathogenic
${HPO_CODE}             HP:0003124
${HPO_DESCRIPTION}      Paciente apresenta hipercolesterolemia familiar hereditária com níveis elevados de LDL
${SEVERITY}             moderate
${AGE_OF_ONSET}         adult

*** Test Cases ***
Cenário: Pesquisadora Ana acessa o sistema GenoTrack
    [Documentation]    Verifica se a pesquisadora consegue acessar o sistema corretamente
    [Tags]    login    interface
    Dado que Ana acessa o sistema GenoPhen Tracker
    Então ela deve ver a interface principal do sistema
    E deve estar logada como pesquisadora Ana Silva

Cenário: Validação de formato de ID do paciente
    [Documentation]    Testa a validação do formato BR-PACIENTE-XXXX
    [Tags]    validation    patient_id
    Dado que Ana acessa o sistema GenoPhen Tracker
    Quando ela tenta registrar um paciente com ID inválido "INVALID-FORMAT"
    Então o sistema deve exibir erro de formato de ID
    E não deve permitir o registro

Cenário: Validação de código HPO
    [Documentation]    Testa a validação do formato HP:0000000 para códigos HPO
    [Tags]    validation    hpo
    Dado que Ana acessa o sistema GenoPhen Tracker
    Quando ela visualiza os códigos HPO disponíveis
    Então todos os códigos devem seguir o formato HP:0000000
    E devem estar associados a termos válidos

Cenário: Registro completo do paciente BR-PACIENTE-0321
    [Documentation]    Testa o fluxo completo de registro do caso de estudo
    [Tags]    registration    complete_flow
    Dado que Ana acessa o sistema GenoPhen Tracker
    Quando ela registra o paciente BR-PACIENTE-0321 com o gene LDLR e fenótipo HP:0003124
    Então o paciente deve ser registrado com sucesso
    E deve aparecer uma notificação de sucesso
    E os dados devem ser salvos no sistema

Cenário: Visualização da associação gene-fenótipo
    [Documentation]    Verifica se a associação entre LDLR e hipercolesterolemia é exibida corretamente
    [Tags]    association    visualization
    Dado que o paciente BR-PACIENTE-0321 está registrado no sistema
    Quando Ana consulta os dados do paciente
    Então ela deve visualizar o vínculo entre o gene LDLR e a hipercolesterolemia familiar
    E a associação deve mostrar o código HP:0003124
    E deve exibir a descrição do fenótipo

Cenário: Busca de paciente por ID
    [Documentation]    Testa a funcionalidade de busca por ID do paciente
    [Tags]    search    patient_lookup
    Dado que o paciente BR-PACIENTE-0321 está registrado no sistema
    Quando Ana busca pelo ID "BR-PACIENTE-0321"
    Então o sistema deve retornar os dados do paciente
    E deve exibir informações genômicas e fenotípicas
    E deve mostrar a idade calculada corretamente

Cenário: Busca de pacientes por gene
    [Documentation]    Testa a busca de pacientes que possuem variantes em um gene específico
    [Tags]    search    gene_filter
    Dado que existem pacientes com variantes no gene LDLR
    Quando Ana filtra pacientes por gene "LDLR"
    Então o sistema deve retornar apenas pacientes com variantes em LDLR
    E deve incluir o paciente BR-PACIENTE-0321

Cenário: Busca de pacientes por fenótipo
    [Documentation]    Testa a busca de pacientes com fenótipo específico
    [Tags]    search    phenotype_filter
    Dado que existem pacientes com fenótipo HP:0003124
    Quando Ana filtra pacientes por código HPO "HP:0003124"
    Então o sistema deve retornar pacientes com hipercolesterolemia
    E deve incluir o paciente BR-PACIENTE-0321
