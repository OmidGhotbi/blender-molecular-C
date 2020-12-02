import os, struct

import bpy

from . import utils, cache, operators


is_rendering = False


def get_debug_values(debug_file_path):
    if not os.path.exists(debug_file_path) or not os.path.isfile(debug_file_path):
        return
    with open(debug_file_path, 'rb') as file:
        data = bytearray(file.read())
    p = 0
    values_count = struct.unpack('<I', data[p : p + 4])[0]
    p += 4
    value_format = struct.unpack('<B', data[p : p + 1])[0]
    p += 1
    values = [None, ] * values_count * 3
    if value_format == 0:
        format_string = '<f'
        format_size = 4
        for i in range(0, values_count * 3, 3):
            value = struct.unpack(format_string, data[p : p + format_size])[0]
            p += format_size
            values[i] = value
            values[i + 1] = 0.0
            values[i + 2] = 0.0
    return values


def get_par_attrs(psys, scene, cache_folder):
    par_attrs = None
    cache_file_name = '{}_{:0>6}.bin'.format(psys.settings.name, scene.frame_current)
    file_path = os.path.join(cache_folder, cache_file_name)
    par_cache = cache.ParticlesCache()
    if os.path.exists(file_path) and os.path.isfile(file_path):
        par_attrs = par_cache.read(file_path)
    return par_attrs


@bpy.app.handlers.persistent
def render_post_handler(scene):
    global is_rendering
    is_rendering = False


@bpy.app.handlers.persistent
def render_init_handler(scene):
    global is_rendering
    is_rendering = True


@bpy.app.handlers.persistent
def frame_change_pre_handler(scene):
    global is_rendering
    if is_rendering:
        return
    if scene.mol_simrun:
        return
    cache_folder = bpy.path.abspath(scene.mol_cache_folder)
    for ob in bpy.data.objects:
        obj = utils.get_object(bpy.context, ob)
        for psys in obj.particle_systems:
            if psys.settings.mol_active:
                if psys.point_cache.is_baked:
                    continue
                par_attrs = get_par_attrs(psys, scene, cache_folder)
                if par_attrs:
                    loc = par_attrs[cache.LOCATION]
                    psys.particles.foreach_set('location', loc)
                    if not psys.settings.mol_use_debug_par_attr:
                        vel = par_attrs.get(cache.VELOCITY, None)
                        if vel:
                            psys.particles.foreach_set('velocity', vel)
                    else:
                        attr_name = psys.settings.mol_debug_par_attr_name
                        # link
                        if attr_name == 'LINK_FRICTION':
                            attr = 'link_friction'
                        elif attr_name == 'LINK_TENSION':
                            attr = 'link_tension'
                        elif attr_name == 'LINK_STIFFNESS':
                            attr = 'link_stiffness'
                        elif attr_name == 'LINK_ESTIFFNESS':
                            attr = 'link_estiffness'
                        elif attr_name == 'LINK_DAMPING':
                            attr = 'link_damping'
                        elif attr_name == 'LINK_EDAMPING':
                            attr = 'link_edamping'
                        elif attr_name == 'LINK_BROKEN':
                            attr = 'link_broken'
                        elif attr_name == 'LINK_EBROKEN':
                            attr = 'link_ebroken'
                        # relink
                        if attr_name == 'RELINK_FRICTION':
                            attr = 'relink_friction'
                        elif attr_name == 'RELINK_TENSION':
                            attr = 'relink_tension'
                        elif attr_name == 'RELINK_STIFFNESS':
                            attr = 'relink_stiffness'
                        elif attr_name == 'RELINK_ESTIFFNESS':
                            attr = 'relink_estiffness'
                        elif attr_name == 'RELINK_DAMPING':
                            attr = 'relink_damping'
                        elif attr_name == 'RELINK_EDAMPING':
                            attr = 'relink_edamping'
                        elif attr_name == 'RELINK_BROKEN':
                            attr = 'relink_broken'
                        elif attr_name == 'RELINK_EBROKEN':
                            attr = 'relink_ebroken'
                        elif attr_name == 'RELINK_LINKING':
                            attr = 'relink_chance'

                        debug_file_name = '{}_{}.bin'.format(psys.settings.name, attr)
                        debug_file_path = os.path.join(cache_folder, debug_file_name)
                        values = get_debug_values(debug_file_path)
                        if values:
                            psys.particles.foreach_set('velocity', values)
                            psys.particles.foreach_set('angular_velocity', values)
                        else:
                            values = [0.0, ] * len(psys.particles) * 3
                            psys.particles.foreach_set('velocity', values)
                            psys.particles.foreach_set('angular_velocity', values)
                else:
                    null_values = [-1000.0, ] * len(psys.particles) * 3
                    psys.particles.foreach_set('location', null_values)
                    psys.particles.foreach_set('velocity', null_values)
                    psys.particles.foreach_set('angular_velocity', null_values)


def register():
    bpy.app.handlers.frame_change_post.append(frame_change_pre_handler)
    bpy.app.handlers.render_init.append(render_init_handler)
    bpy.app.handlers.render_post.append(render_post_handler)


def unregister():
    bpy.app.handlers.render_init.remove(render_init_handler)
    bpy.app.handlers.render_post.remove(render_post_handler)
    bpy.app.handlers.frame_change_post.remove(frame_change_pre_handler)
