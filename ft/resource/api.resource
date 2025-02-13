*** Settings ***
Library    REST                     http://127.0.0.1:7001
Resource   common.resource

*** Variables ***
${PLUGIN-MODBUS-TCP}    modbus-tcp
${PLUGIN-MQTT}          mqtt
${PLUGIN-EKUIPER}       ekuiper

${NODE_DRIVER}	1
${NODE_APP}	2

${NODE_STATE_IDLE}	0
${NODE_STATE_INIT}	1
${NODE_STATE_READY}	2
${NODE_STATE_RUNNING}	3
${NODE_STATE_STOP}	4

${NODE_LINK_STATE_DISCONNECTED}    0
${NODE_LINK_STATE_CONNECTING}      1
${NODE_LINK_STATE_CONNECTED}       2

${NODE_CTL_START}	0
${NODE_CTL_STOP}	1

${TAG_ATTRIBUTE_READ}	1
${TAG_ATTRIBUTE_WRITE}	2
${TAG_ATTRIBUTE_SUBSCRIBE}	4
${TAG_ATTRIBUTE_RW}	3

${TAG_TYPE_INT8}	  1
${TAG_TYPE_UINT8}	  2
${TAG_TYPE_INT16}	  3
${TAG_TYPE_UINT16}	4
${TAG_TYPE_INT32}	  5
${TAG_TYPE_UINT32}	6
${TAG_TYPE_INT64}	  7
${TAG_TYPE_UINT64}	8
${TAG_TYPE_FLOAT}	  9
${TAG_TYPE_DOUBLE}	10
${TAG_TYPE_BIT}	    11
${TAG_TYPE_BOOL}	  12
${TAG_TYPE_STRING}	13
${TAG_TYPE_BYTE}	  14

*** Keywords ***
Check Error Code
  [Arguments]         ${result}               ${errcode}
  Integer             response body error     ${errcode}

Check Response Status
  [Arguments]         ${result}               ${status}
  Integer             response status         ${status}

LOGIN
  POST                /api/v2/login           {"name": "admin", "pass":"0000"}

  Integer             response status         200

  ${token}            String                  $.token
  ${jwt} =            Catenate                Bearer                          ${token}[0]
  Set Headers         {"Authorization":"${jwt}"}

  [Return]            ${token}[0]

Add Node
  [Arguments]   ${name}   ${plugin}
  POST          /api/v2/node  {"name": "${name}", "plugin": "${plugin}"}
  ${res}        Object  response body
  [RETURN]      ${res}[0]

Del Node
  [Arguments]   ${name}
  DELETE        /api/v2/node  {"name": "${name}"}
  ${res} =            Object  response body
  [RETURN]            ${res}[0]

Get Nodes
  [Arguments]         ${node_type}
  GET                 /api/v2/node?type=${node_type}
  ${res} =            Object  response body
  [RETURN]            ${res}[0]

Node Setting
  [Arguments]         ${name}              ${config}
  POST                /api/v2/node/setting    {"node": "${name}", "params": ${config}}
  ${res} =            Object  response body
  [RETURN]            ${res}[0]

Get Node Setting
  [Arguments]         ${name}
  GET                 /api/v2/node/setting?node=${name}
  ${res} =            Object  response body
  [RETURN]            ${res}[0]

Get Node State
  [Arguments]         ${name}
  GET                 /api/v2/node/state?node=${name}
  ${res} =            Object  response body
  [RETURN]            ${res}[0]

Node Ctl
  [Arguments]         ${node}  ${cmd}
  POST                /api/v2/node/ctl        {"node": "${node}", "cmd": ${cmd}}
  ${res} =            Object  response body
  [RETURN]            ${res}[0]

Add Group
  [Arguments]         ${node}              ${group}            ${interval}
  POST                /api/v2/group         {"group": "${group}", "node": "${node}", "interval": ${interval}}
  ${res} =            Object  response body
  [RETURN]            ${res}[0]

Del Group
  [Arguments]         ${node}              ${group}
  DELETE              /api/v2/group         {"node": "${node}", "group": "${group}"}
  ${res} =            Object  response body
  [RETURN]            ${res}[0]

Get Group
  [Arguments]         ${node}
  GET                 /api/v2/group?node=${node}
  ${res} =            Object  response body
  [RETURN]            ${res}[0]

Subscribe Group
  [Arguments]         ${app}       ${driver}                ${group}
  POST                /api/v2/subscribe  {"app": "${app}", "driver": "${driver}", "group": "${group}"}
  ${res} =            Object  response body
  [RETURN]            ${res}[0]

Unsubscribe Group
  [Arguments]         ${app}       ${driver}                ${group}
  DELETE              /api/v2/subscribe       {"app": "${app}", "driver": "${driver}", "group": "${group}"}
  ${res} =            Object  response body
  [RETURN]            ${res}[0]

Get Subscribe Group
  [Arguments]         ${app}
  GET                 /api/v2/subscribe?app=${app}
  ${res} =            Object  response body
  [RETURN]            ${res}[0]

Add Tags
  [Arguments]         ${node}   ${group}    ${tags}
  POST                /api/v2/tags            {"node": "${node}", "group": "${group}", "tags": [${tags}]}
  ${res} =            Object  response body

  [RETURN]            ${res}[0]

Get Tags
  [Arguments]         ${node}              ${group}
  GET                 /api/v2/tags?node=${node}&group=${group}
  ${res} =            Object  response body
  [RETURN]            ${res}[0]

Update Tags
  [Arguments]         ${node}   ${group}  ${tags}
  Put                 /api/v2/tags            {"node": "${node}", "group": "${group}", "tags": [${tags}]}
  ${res} =            Object  response body

  [RETURN]            ${res}[0]

Del Tags
  [Arguments]         ${node}              ${group}                      ${tags}
  DELETE              /api/v2/tags            {"node": "${node}", "group": "${group}", "tags": [${tags}]}
  ${res} =            Object  response body

  [RETURN]            ${res}[0]

Get Tag ID
  [Arguments]         ${node_id}              ${group}                      ${tag_name}
  ${res} =            Get Tags                ${node_id}                    ${group}
  Check Response Status                       ${res}                        200

  ${id} =             Tag Find By Name        ${res}[tags]                  ${tag_name}
  Should Not Be Equal As Integers             ${id}                         0

  [Return]            ${id}

Read Tags
  [Arguments]         ${node}              ${group}
  POST                /api/v2/read            {"node": "${node}", "group": "${group}"}
  ${res} =            Object  response body
  [RETURN]            ${res}[0]

Write Tags
  [Arguments]         ${node}              ${group}                      ${tag}     ${value}
  POST                /api/v2/write           {"node": "${node}", "group": "${group}", "tag": "${tag}", "value": ${value}}
  ${res} =            Object  response body
  [RETURN]            ${res}[0]
