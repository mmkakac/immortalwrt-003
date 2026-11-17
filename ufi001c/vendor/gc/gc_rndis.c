// SPDX-License-Identifier: GPL-2.0-only
/*
 * Copyright (C) 2021-2022 HandsomeMod Project
 *
 * Handsomeyingyan <handsomeyingyan@gmail.com>
 *
 * GC(Gadget Controller) is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 */

#include "gc_rndis.h"

static int gc_rebind_rndis_first(usbg_gadget *gadget, usbg_config *config,
                                 usbg_function *f_rndis)
{
    usbg_binding *binding = usbg_get_first_binding(config);
    while (binding != NULL) {
        usbg_binding *next = usbg_get_next_binding(binding);
        usbg_rm_binding(binding);
        binding = next;
    }

    const char *rndis_instance = usbg_get_function_instance(f_rndis);
    if (rndis_instance == NULL)
        return GC_FAILED;

    int usbg_ret = usbg_add_config_function(config, rndis_instance, f_rndis);
    if (usbg_ret != USBG_SUCCESS)
        return GC_FAILED;

    usbg_function *f = usbg_get_first_function(gadget);
    while (f != NULL) {
        if (f != f_rndis) {
            const char *instance = usbg_get_function_instance(f);
            if (instance == NULL)
                return GC_FAILED;
            usbg_ret = usbg_add_config_function(config, instance, f);
            if (usbg_ret != USBG_SUCCESS)
                return GC_FAILED;
        }
        f = usbg_get_next_function(f);
    }

    return GC_SUCCESS;
}

int gc_rndis_create(int argc,char *argv[],gc_generic_info info)
{
    usbg_gadget *gadget = gc_init(info);

    if(gadget == NULL)
        return GC_FAILED;

    usbg_function *f_rndis;
    int usbg_ret;

    char *id = gc_generate_id(USBG_F_RNDIS);

    if(id == NULL)
        return GC_FAILED;

    struct usbg_gadget_os_descs g_os_desc = {
            .use = true,
            .b_vendor_code = 0xBC,
            .qw_sign = "MSFT100",
    };

    struct usbg_function_os_desc f_os_desc = {
            .compatible_id = "RNDIS",
            .sub_compatible_id = "5162001",
    };

    usbg_ret = usbg_create_function(gadget,USBG_F_RNDIS,id,NULL,&f_rndis);
    if(usbg_ret != USBG_SUCCESS){
        fprintf(stderr,"failed to create rndis function!  (maybe kernel module not loaded?) \n");
        gc_clean();
        return GC_FAILED;
    }

    /* for now we only create one config file */
    usbg_config *config = gc_get_config(gadget);
    if (gc_set_net_addrs(f_rndis, id) != GC_SUCCESS) {
        gc_clean();
        return GC_FAILED;
    }

    usbg_ret = usbg_add_config_function(config,id,f_rndis);
    if(usbg_ret != USBG_SUCCESS){
        fprintf(stderr,"failed to bind rndis config to function! \n");
        gc_clean();
        return GC_FAILED;
    }

    if (gc_rebind_rndis_first(gadget, config, f_rndis) != GC_SUCCESS) {
        fprintf(stderr,"failed to reorder config bindings! \n");
        gc_clean();
        return GC_FAILED;
    }

    usbg_ret = usbg_set_interf_os_desc(f_rndis, "rndis", &f_os_desc);
    if (usbg_ret != USBG_SUCCESS) {
        fprintf(stderr, "Error setting rndis function OS desc\n");
        gc_clean();
        return GC_FAILED;
    }

    usbg_ret = usbg_set_gadget_os_descs(gadget, &g_os_desc);
    if (usbg_ret != USBG_SUCCESS) {
        fprintf(stderr, "Error setting gadget OS desc\n");
        gc_clean();
        return GC_FAILED;
    }

    usbg_ret = usbg_set_os_desc_config(gadget, config);
    if (usbg_ret != USBG_SUCCESS) {
        fprintf(stderr, "Error setting gadget OS desc config\n");
        gc_clean();
        return GC_FAILED;
    }

    gc_clean();
    return GC_SUCCESS;
}

