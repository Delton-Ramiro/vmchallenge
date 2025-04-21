*** Settings ***
Library           RequestsLibrary
Library           Collections
Library           BuiltIn

Suite Setup       Create Session    api    http://localhost

*** Variables ***
${VALID_EMAIL}     testssass@example.com
${VALID_USERNAME}  testssass
${VALID_PASSWORD}  passwordestrnaha
${VALID_FULL_NAME}    Test User
${FORM_HEADER}     Content-Type=application/json

*** Test Cases ***

Credenciais Válidas
    [Documentation]    Teste com credenciais válidas.
    ${data}=    Create Dictionary    email=${VALID_EMAIL}    username=${VALID_USERNAME}    full_name=${VALID_FULL_NAME}    password=${VALID_PASSWORD}    disabled=false
    ${headers}=    Create Dictionary    ${FORM_HEADER}
    ${resp}=    Post Request    api    /users    json=${data}    headers=${headers}
    Should Be Equal As Integers    ${resp.status_code}    201

Email Válido, Senha Inválida
    [Documentation]    Teste com email válido, mas senha inválida.
    ${data}=    Create Dictionary    email=${VALID_EMAIL}    username=${VALID_USERNAME}    full_name=${VALID_FULL_NAME}    password=wrongpassword    disabled=false
    ${headers}=    Create Dictionary    ${FORM_HEADER}
    ${resp}=    Post Request    api    /users    json=${data}    headers=${headers}
    Should Be Equal As Integers    ${resp.status_code}    400

Formato de Email Inválido
    [Documentation]    Teste com formato de email inválido.
    ${data}=    Create Dictionary    email=invalid-email-format    username=${VALID_USERNAME}    full_name=${VALID_FULL_NAME}    password=${VALID_PASSWORD}    disabled=false
    ${headers}=    Create Dictionary    ${FORM_HEADER}
    ${resp}=    Post Request    api    /users    json=${data}    headers=${headers}
    Should Be Equal As Integers    ${resp.status_code}    400

Apenas Senha Providenciada
    [Documentation]    Teste com apenas a senha fornecida, sem email ou nome de usuário.
    ${data}=    Create Dictionary    password=somepassword    disabled=false
    ${headers}=    Create Dictionary    ${FORM_HEADER}
    ${resp}=    Post Request    api    /users    json=${data}    headers=${headers}
    Should Be Equal As Integers    ${resp.status_code}    400

Sem Corpo Providenciado
    [Documentation]    Teste sem fornecer corpo na requisição.
    ${headers}=    Create Dictionary    ${FORM_HEADER}
    ${resp}=    Post Request    api    /users    headers=${headers}
    Should Be Equal As Integers    ${resp.status_code}    400

Email com Caracteres Especiais
    [Documentation]    Teste com email contendo caracteres especiais.
    ${data}=    Create Dictionary    email="tést@exämple.com"    username=${VALID_USERNAME}    full_name=${VALID_FULL_NAME}    password=${VALID_PASSWORD}    disabled=false
    ${headers}=    Create Dictionary    ${FORM_HEADER}
    ${resp}=    Post Request    api    /users    json=${data}    headers=${headers}
    Should Be Equal As Integers    ${resp.status_code}    201

Email Sem Domínio
    [Documentation]    Teste com email sem domínio.
    ${data}=    Create Dictionary    email=user@    username=${VALID_USERNAME}    full_name=${VALID_FULL_NAME}    password=${VALID_PASSWORD}    disabled=false
    ${headers}=    Create Dictionary    ${FORM_HEADER}
    ${resp}=    Post Request    api    /users    json=${data}    headers=${headers}
    Should Be Equal As Integers    ${resp.status_code}    400

Credenciais Sem Campo de Email
    [Documentation]    Teste sem o campo de email.
    ${data}=    Create Dictionary    username=${VALID_USERNAME}    full_name=${VALID_FULL_NAME}    password=${VALID_PASSWORD}    disabled=false
    ${headers}=    Create Dictionary    ${FORM_HEADER}
    ${resp}=    Post Request    api    /users    json=${data}    headers=${headers}
    Should Be Equal As Integers    ${resp.status_code}    400

Credenciais Sem Campo de Nome de Usuário
    [Documentation]    Teste sem o campo de nome de usuário.
    ${data}=    Create Dictionary    email=${VALID_EMAIL}    full_name=${VALID_FULL_NAME}    password=${VALID_PASSWORD}    disabled=false
    ${headers}=    Create Dictionary    ${FORM_HEADER}
    ${resp}=    Post Request    api    /users    json=${data}    headers=${headers}
    Should Be Equal As Integers    ${resp.status_code}    400
