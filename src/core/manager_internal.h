/**
 * NEURON IIoT System for Industry 4.0
 * Copyright (C) 2020-2022 EMQ Technologies Co., Ltd All rights reserved.
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

#ifndef _NEU_MANAGER_INTERNAL_H_
#define _NEU_MANAGER_INTERNAL_H_

#include <nng/nng.h>
#include <nng/supplemental/util/platform.h>

#include "event/event.h"
#include "persist/persist.h"

#include "node_manager.h"
#include "plugin_manager.h"
#include "subscribe.h"

typedef struct neu_manager {
    nng_socket      socket;
    neu_events_t *  events;
    neu_event_io_t *loop;

    neu_plugin_manager_t *plugin_manager;
    neu_node_manager_t *  node_manager;
    neu_subscribe_mgr_t * subscribe_manager;

    neu_persister_t *persister;
} neu_manager_t;

int       neu_manager_add_plugin(neu_manager_t *manager, const char *library);
int       neu_manager_del_plugin(neu_manager_t *manager, const char *plugin);
UT_array *neu_manager_get_plugins(neu_manager_t *manager);

int       neu_manager_add_node(neu_manager_t *manager, const char *node_name,
                               const char *plugin_name);
int       neu_manager_del_node(neu_manager_t *manager, const char *node_name);
UT_array *neu_manager_get_nodes(neu_manager_t *manager, neu_node_type_e type);

int       neu_manager_subscribe(neu_manager_t *manager, const char *app,
                                const char *driver, const char *group);
int       neu_manager_unsubscribe(neu_manager_t *manager, const char *app,
                                  const char *driver, const char *group);
UT_array *neu_manager_get_sub_group(neu_manager_t *manager, const char *app);

int neu_manager_get_adapter_info(neu_manager_t *manager, const char *name,
                                 neu_persist_adapter_info_t *info);

void neu_manager_notify_app_sub(neu_manager_t *manager, const char *app,
                                const char *driver, const char *group);
void neu_manager_notify_app_unsub(neu_manager_t *manager, const char *app,
                                  const char *driver, const char *group);
void neu_manager_notify_app_unsub_update(neu_manager_t *manager,
                                         const char *driver, const char *group);
void neu_manager_notify_app_unsub_driver_update(neu_manager_t *manager,
                                                const char *   driver);
void neu_manager_notify_app_sub_update(neu_manager_t *manager,
                                       const char *driver, const char *group);

#endif
