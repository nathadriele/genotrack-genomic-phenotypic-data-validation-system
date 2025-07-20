*** Settings ***
Documentation    Keywords customizadas para testes do GenoTrack
Library          SeleniumLibrary
Library          RequestsLibrary
Library          Collections
Library          String
Library          DateTime

*** Keywords ***
Setup Test Environment
    [Documentation]    Configura o ambiente de teste
    Open Browser    ${BASE_URL}    ${BROWSER}
    Maximize Browser Window
    Set Selenium Speed    0.2s
    Create Session    api    ${API_BASE_URL}

Teardown Test Environment
    [Documentation]    Limpa o ambiente de teste
    Close All Browsers
    Delete All Sessions

Setup Test Case
    [Documentation]    Preparação antes de cada teste
    Go To    ${BASE_URL}
    Wait Until Page Contains Element    .header    timeout=10s

Teardown Test Case
    [Documentation]    Limpeza após cada teste
    Capture Page Screenshot
    Clear Browser Cache

# Keywords de navegação e interface
Dado que Ana acessa o sistema GenoPhen Tracker
    [Documentation]    Simula o acesso da pesquisadora ao sistema
    Go To    ${BASE_URL}
    Wait Until Page Contains Element    .header h1    timeout=10s
    Page Should Contain Element    xpath://span[contains(text(), '${RESEARCHER_NAME}')]

Então ela deve ver a interface principal do sistema
    [Documentation]    Verifica se a interface principal está carregada
    Page Should Contain Element    .header h1
    Element Should Contain    .header h1    GenoTrack
    Page Should Contain Element    .tabs
    Page Should Contain Element    [data-tab="register"]
    Page Should Contain Element    [data-tab="search"]
    Page Should Contain Element    [data-tab="associations"]

E deve estar logada como pesquisadora Ana Silva
    [Documentation]    Verifica se o nome da pesquisadora está exibido
    Element Should Contain    .user-info span    Pesquisadora: ${RESEARCHER_NAME}

# Keywords de validação
Quando ela tenta registrar um paciente com ID inválido "${invalid_id}"
    [Documentation]    Tenta registrar paciente com ID inválido
    Input Text    id:patient-id    ${invalid_id}
    Input Text    id:patient-name    Teste Paciente
    Input Text    id:birth-date    1980-01-01
    Select From List By Value    id:gender    M
    Click Button    xpath://button[@type='submit']

Então o sistema deve exibir erro de formato de ID
    [Documentation]    Verifica se erro de validação é exibido
    Element Should Be Visible    id:patient-id:invalid

E não deve permitir o registro
    [Documentation]    Confirma que o registro não foi realizado
    Page Should Not Contain    Paciente registrado com sucesso

Quando ela visualiza os códigos HPO disponíveis
    [Documentation]    Acessa a lista de códigos HPO
    Click Element    id:hpo-code

Então todos os códigos devem seguir o formato HP:0000000
    [Documentation]    Valida formato dos códigos HPO
    ${options}=    Get WebElements    xpath://select[@id='hpo-code']/option[@value!='']
    FOR    ${option}    IN    @{options}
        ${value}=    Get Element Attribute    ${option}    value
        Should Match Regexp    ${value}    ^HP:\\d{7}$
    END

E devem estar associados a termos válidos
    [Documentation]    Verifica se códigos têm descrições válidas
    ${options}=    Get WebElements    xpath://select[@id='hpo-code']/option[@value!='']
    FOR    ${option}    IN    @{options}
        ${text}=    Get Text    ${option}
        Should Contain    ${text}    HP:
        Should Not Be Empty    ${text}
    END

# Keywords de registro de paciente
Quando ela registra o paciente BR-PACIENTE-0321 com o gene LDLR e fenótipo HP:0003124
    [Documentation]    Executa o registro completo do paciente do caso de estudo
    Preencher dados do paciente
    Preencher dados genômicos
    Preencher dados fenotípicos
    Click Button    xpath://button[@type='submit']

Preencher dados do paciente
    [Documentation]    Preenche informações básicas do paciente
    Input Text    id:patient-id    ${PATIENT_ID}
    Input Text    id:patient-name    ${PATIENT_NAME}
    Input Text    id:birth-date    ${BIRTH_DATE}
    Select From List By Value    id:gender    ${GENDER}

Preencher dados genômicos
    [Documentation]    Preenche informações genômicas
    Select From List By Value    id:gene-symbol    ${GENE_SYMBOL}
    Input Text    id:chromosome    ${CHROMOSOME}
    Input Text    id:position    ${POSITION}
    Select From List By Value    id:variant-type    ${VARIANT_TYPE}
    Input Text    id:reference-allele    ${REFERENCE_ALLELE}
    Input Text    id:alternate-allele    ${ALTERNATE_ALLELE}
    Select From List By Value    id:pathogenicity    ${PATHOGENICITY}

Preencher dados fenotípicos
    [Documentation]    Preenche informações fenotípicas
    Select From List By Value    id:hpo-code    ${HPO_CODE}
    Select From List By Value    id:severity    ${SEVERITY}
    Select From List By Value    id:age-of-onset    ${AGE_OF_ONSET}
    Input Text    id:phenotype-description    ${HPO_DESCRIPTION}

Então o paciente deve ser registrado com sucesso
    [Documentation]    Verifica se o registro foi bem-sucedido
    Wait Until Page Contains    registrado com sucesso    timeout=10s

E deve aparecer uma notificação de sucesso
    [Documentation]    Verifica se notificação de sucesso aparece
    Wait Until Element Is Visible    .notification.success    timeout=5s
    Element Should Contain    .notification.success    sucesso

E os dados devem ser salvos no sistema
    [Documentation]    Verifica se dados foram persistidos via API
    ${response}=    GET On Session    api    /patients
    Should Be Equal As Strings    ${response.status_code}    200
    ${patients}=    Set Variable    ${response.json()}
    Should Contain    ${patients}    ${PATIENT_ID}
