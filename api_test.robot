*** Settings ***
Library           RequestsLibrary
Library           Collections
Library           JSONLibrary
Library           String
Suite Setup       Create Session    api    http://localhost

*** Variables ***
${BASE_URL}       http://localhost
${USER_EMAIL}     matiasdamasio@examplo.com
${USERNAME}       matias
${FULL_NAME}      matias damas
${PASSWORD}       string
${AUTH_TOKEN}     
${POST_ID}        

*** Test Cases ***
Criar Usuário
    [Documentation]    Cria usuário e valida resposta com status 201 e schema.
    ${data}=    Create Dictionary
    ...    email=${USER_EMAIL}
    ...    username=${USERNAME}
    ...    full_name=${FULL_NAME}
    ...    disabled=${False}
    ...    password=${PASSWORD}
    ${response}=    Post Request    api    /users    json=${data}
    Should Be Equal As Integers    ${response.status_code}    201
    ${body}=    To Json    ${response.content}
    Dictionary Should Contain Key    ${body}    id
    Dictionary Should Contain Value    ${body}    ${USER_EMAIL}
    Set Suite Variable    ${USER_ID}    ${body['id']}

TC_API_009 - Autentica Usuário
    [Documentation]    Autentica usuário criado e guarda o token de acesso (form-urlencoded).
    ${credentials}=    Create Dictionary
    ...    username=${USERNAME}
    ...    password=${PASSWORD}
    ${headers}=    Create Dictionary
    ...    Content-Type=application/x-www-form-urlencoded
    ${response}=    Post Request    api    /token    data=${credentials}    headers=${headers}
    Should Be Equal As Integers    ${response.status_code}    200
    ${body}=    To Json    ${response.content}
    Set Suite Variable    ${AUTH_TOKEN}    Bearer ${body['access_token']}

TC_API_010 - Obter Informações do Próprio Usuário
    [Documentation]    Obtém dados do próprio usuário autenticado.
    ${headers}=    Create Dictionary    Authorization=${AUTH_TOKEN}
    ${response}=    Get Request    api    /users/me    headers=${headers}
    Should Be Equal As Integers    ${response.status_code}    200
    ${body}=    To Json    ${response.content}
    Dictionary Should Contain Value    ${body}    ${USERNAME}

TC_API_011 - Obter Itens do Próprio Usuário
    [Documentation]    Obtém informações do próprio usuário autenticado.
    ${headers}=    Create Dictionary    Authorization=${AUTH_TOKEN}
    ${response}=    Get Request    api    /users/me/items    headers=${headers}
    Should Be Equal As Integers    ${response.status_code}    200
    Should Be String    ${response.content}

TC_API_012 - Obter Todos os Posts com Token
    [Documentation]    Obtém todos os posts autenticado.
    ${headers}=    Create Dictionary    Authorization=${AUTH_TOKEN}
    ${response}=    Get Request    api    /posts/?skip=0&limit=100    headers=${headers}
    Should Be Equal As Integers    ${response.status_code}    200
    ${body}=    To Json    ${response.content}
    Should Be True    ${body} != None


TC_API_013 - Obter Todos os Posts sem Token
    [Documentation]    Tenta obter todos os posts sem autenticação pois a api é publica.
    ${response}=    Get Request    api    /posts/?skip=0&limit=100
    Should Be Equal As Integers    ${response.status_code}    401
    ${body}=    To Json    ${response.content}
    Should Be Equal    ${body['detail']}    Not authenticated
    

TC_API_014 - Criar Post
    [Documentation]    Cria post autenticado e guarda ID.
    ${headers}=    Create Dictionary    Authorization=${AUTH_TOKEN}
    ${data}=    Create Dictionary
    ...    title=amanha estarei
    ...    content=testando
    ...    public=${True}
    ${response}=    Post Request    api    /posts    headers=${headers}    json=${data}
    Should Be Equal As Integers    ${response.status_code}    201
    ${body}=    To Json    ${response.content}
    Set Suite Variable    ${POST_ID}    ${body['id']}

TC_API_015 - Atualizar Post
    [Documentation]    Atualiza o post criado com novo título.
    ${headers}=    Create Dictionary    Authorization=${AUTH_TOKEN}
    ${data}=    Create Dictionary
    ...    title=depois de amanha
    ...    content=exato
    ...    public=${True}
    ${response}=    Put Request    api    /posts/${POST_ID}    headers=${headers}    json=${data}
    Should Be Equal As Integers    ${response.status_code}    200

TC_API_016 - Apagar Post
    [Documentation]    Deleta o post criado.
    ${headers}=    Create Dictionary    Authorization=${AUTH_TOKEN}
    ${response}=    Delete Request    api    /posts/${POST_ID}    headers=${headers}
    Should Be Equal As Integers    ${response.status_code}    204

TC_API_016 - Obter Post Apagado por ID
    [Documentation]    Tenta buscar o post Apagado, deve falhar.
    ${headers}=    Create Dictionary    Authorization=${AUTH_TOKEN}
    ${response}=    Post Request    api    /posts/${POST_ID}    headers=${headers}
    Should Be Equal As Integers    ${response.status_code}    202
