/**
 * NEURON IIoT System for Industry 4.0
 * Copyright (C) 2020-2021 EMQ Technologies Co., Ltd All rights reserved.
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 **/

/*
 * DO NOT EDIT THIS FILE MANUALLY!
 * It was automatically generated by `json-autotype`.
 */

#include <stdlib.h>
#include <string.h>

#include "json/json.h"

#include "persist_json_plugin.h"

int neu_json_decode_plugin_req(char *buf, neu_json_plugin_req_t **result)
{
    int                    ret      = 0;
    void *                 json_obj = NULL;
    neu_json_plugin_req_t *req      = calloc(1, sizeof(neu_json_plugin_req_t));
    if (req == NULL) {
        return -1;
    }

    json_obj = neu_json_decode_new(buf);

    req->n_plugin = neu_json_decode_array_size_by_json(json_obj, "plugins");
    req->plugins  = calloc(req->n_plugin, sizeof(neu_json_plugin_req_plugin_t));
    neu_json_plugin_req_plugin_t *p_plugin = req->plugins;
    for (int i = 0; i < req->n_plugin; i++) {
        neu_json_elem_t plugin_elems[] = { {
                                               .name = "plugin_lib_name",
                                               .t    = NEU_JSON_STR,
                                           },
                                           {
                                               .name = "name",
                                               .t    = NEU_JSON_STR,
                                           },
                                           {
                                               .name = "kind",
                                               .t    = NEU_JSON_INT,
                                           },
                                           {
                                               .name = "adapter_type",
                                               .t    = NEU_JSON_INT,
                                           } };
        ret = neu_json_decode_array_by_json(json_obj, "plugins", i,
                                            NEU_JSON_ELEM_SIZE(plugin_elems),
                                            plugin_elems);
        if (ret != 0) {
            goto decode_fail;
        }

        p_plugin->plugin_lib_name = plugin_elems[0].v.val_str;
        p_plugin->name            = plugin_elems[1].v.val_str;
        p_plugin->kind            = plugin_elems[2].v.val_int;
        p_plugin->adapter_type    = plugin_elems[3].v.val_int;
        p_plugin++;
    }

    *result = req;
    goto decode_exit;

decode_fail:
    if (req->plugins != NULL) {
        free(req->plugins);
    }
    if (req != NULL) {
        free(req);
    }
    ret = -1;

decode_exit:
    if (json_obj != NULL) {
        neu_json_decode_free(json_obj);
    }
    return ret;
}

void neu_json_decode_plugin_req_free(neu_json_plugin_req_t *req)
{

    neu_json_plugin_req_plugin_t *p_plugin = req->plugins;
    for (int i = 0; i < req->n_plugin; i++) {
        free(p_plugin->plugin_lib_name);
        free(p_plugin->name);
        p_plugin++;
    }

    free(req->plugins);

    free(req);
}

int neu_json_encode_plugin_resp(void *json_object, void *param)
{
    int                     ret  = 0;
    neu_json_plugin_resp_t *resp = (neu_json_plugin_resp_t *) param;

    void *                         plugin_array = neu_json_array();
    neu_json_plugin_resp_plugin_t *p_plugin     = resp->plugins;
    for (int i = 0; i < resp->n_plugin; i++) {
        neu_json_elem_t plugin_elems[] = {
            {
                .name      = "plugin_lib_name",
                .t         = NEU_JSON_STR,
                .v.val_str = p_plugin->plugin_lib_name,
            },
            {
                .name      = "name",
                .t         = NEU_JSON_STR,
                .v.val_str = p_plugin->name,
            },
            {
                .name      = "kind",
                .t         = NEU_JSON_INT,
                .v.val_int = p_plugin->kind,
            },
            {
                .name      = "adapter_type",
                .t         = NEU_JSON_INT,
                .v.val_int = p_plugin->adapter_type,
            }
        };
        plugin_array = neu_json_encode_array(plugin_array, plugin_elems,
                                             NEU_JSON_ELEM_SIZE(plugin_elems));
        p_plugin++;
    }

    neu_json_elem_t resp_elems[] = { {
        .name         = "plugins",
        .t            = NEU_JSON_OBJECT,
        .v.val_object = plugin_array,
    } };
    ret = neu_json_encode_field(json_object, resp_elems,
                                NEU_JSON_ELEM_SIZE(resp_elems));

    return ret;
}
