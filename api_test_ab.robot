*** Settings ***
Library           RequestsLibrary
Library           Collections
Library           BuiltIn

Suite Setup       Create Session    api    http://localhost

*** Variables ***
${USER_A_EMAIL}     usera@example.com
${USER_A_USERNAME}  usera
${USER_A_PASSWORD}  passwordA
${USER_B_EMAIL}     userb@example.com
${USER_B_USERNAME}  userb
${USER_B_PASSWORD}  passwordB
${TOKEN_A}          
${TOKEN_B}          
${POST_ID_A}        

*** Test Cases ***
Criando dois usuarios
    [Documentation]    Cria dois usuários e autentica ambos.
    ${user_a}=    Create Dictionary
    ...    email=${USER_A_EMAIL}
    ...    username=${USER_A_USERNAME}
    ...    full_name=User A
    ...    disabled=${False}
    ...    password=${USER_A_PASSWORD}
    Post Request    api    /users    json=${user_a}

    ${user_b}=    Create Dictionary
    ...    email=${USER_B_EMAIL}
    ...    username=${USER_B_USERNAME}
    ...    full_name=User B
    ...    disabled=${False}
    ...    password=${USER_B_PASSWORD}
    Post Request    api    /users    json=${user_b}

    ${form_headers}=    Create Dictionary    Content-Type=application/x-www-form-urlencoded

    ${credentials_a}=    Create Dictionary    username=${USER_A_USERNAME}    password=${USER_A_PASSWORD}
    ${resp_a}=    Post Request    api    /token    data=${credentials_a}    headers=${form_headers}
    ${body_a}=    To Json    ${resp_a.content}
    Set Suite Variable    ${TOKEN_A}    Bearer ${body_a['access_token']}

    ${credentials_b}=    Create Dictionary    username=${USER_B_USERNAME}    password=${USER_B_PASSWORD}
    ${resp_b}=    Post Request    api    /token    data=${credentials_b}    headers=${form_headers}
    ${body_b}=    To Json    ${resp_b.content}
    Set Suite Variable    ${TOKEN_B}    Bearer ${body_b['access_token']}

Usuario A Cria Post
    ${headers}=    Create Dictionary    Authorization=${TOKEN_A}
    ${post}=    Create Dictionary
    ...    title=Post A
    ...    content=Conteúdo A
    ...    public=${True}
    ${resp}=    Post Request    api    /posts    headers=${headers}    json=${post}
    Should Be Equal As Integers    ${resp.status_code}    201
    ${body}=    To Json    ${resp.content}
    Set Suite Variable    ${POST_ID_A}    ${body['id']}

Usuario b Tenta ler post de A
    [Documentation]    Deve conseguir ler, pois é público.
    ${headers}=    Create Dictionary    Authorization=${TOKEN_B}
    ${resp}=    Post Request    api    /posts/${POST_ID_A}    headers=${headers}
    Should Be Equal As Integers    ${resp.status_code}    202

Uario B Tenta apagar post de A
    [Documentation]    Deve receber erro 403 ou 404.
    ${headers}=    Create Dictionary    Authorization=${TOKEN_B}
    ${resp}=    Delete Request    api    /posts/${POST_ID_A}    headers=${headers}
    Should Be True    ${resp.status_code} == 403 or ${resp.status_code} == 404
