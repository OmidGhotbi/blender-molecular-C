#cython: profile=False
#cython: boundscheck=False
#cython: cdivision=True

cimport cython
from cython.parallel import threadid
from libc.stdlib cimport malloc, realloc, free, rand, abs

cimport types, data, kd_tree, utils, mol_math
from libc.stdio cimport printf


cdef void create_link(int par_id, int max_link, int parothers_id=-1)nogil:
    cdef types.Links *link = <types.Links *>malloc(1 * cython.sizeof(types.Links))
    cdef int *neighbours = NULL
    cdef int ii = 0
    cdef int neighboursnum = 0
    cdef float rand_max = 32767 
    cdef types.Particle *par = NULL
    cdef types.Particle *par2 = NULL
    cdef types.Particle *fakepar = NULL
    cdef int create_links
    fakepar = <types.Particle *>malloc(1 * cython.sizeof(types.Particle))
    par = &data.parlist[par_id]
    cdef float friction_1 = 0
    cdef float friction_1_random = 0
    cdef float friction_2 = 0
    cdef float friction_2_random = 0
    cdef float frictionrandom = 0
    cdef float tension_1 = 0
    cdef float tension_1_random = 0
    cdef float tension_2 = 0
    cdef float tension_2_random = 0
    cdef float tensionrandom = 0
    cdef float link_stiff_1 = 0
    cdef float stiffrandom_1 = 0
    cdef float link_estiff_1 = 0
    cdef float estiffrandom_1 = 0
    cdef float link_stiff_2 = 0
    cdef float stiffrandom_2 = 0
    cdef float link_estiff_2 = 0
    cdef float estiffrandom_2 = 0
    cdef float stiffrandom = 0
    cdef float estiffrandom = 0
    cdef float damp_1 = 0
    cdef float damp_1_random = 0
    cdef float edamp_1 = 0
    cdef float edamp_1_random = 0
    cdef float damp_2 = 0
    cdef float damp_2_random = 0
    cdef float edamp_2 = 0
    cdef float edamp_2_random = 0
    cdef float damprandom = 0
    cdef float edamprandom = 0
    cdef float broken_1 = 0
    cdef float broken_1_random = 0
    cdef float ebroken_1 = 0
    cdef float ebroken_1_random = 0
    cdef float broken_2 = 0
    cdef float broken_2_random = 0
    cdef float ebroken_2 = 0
    cdef float ebroken_2_random = 0
    cdef float brokrandom = 0
    cdef float ebrokrandom = 0
    cdef float chance_1 = 0
    cdef float chance_1_random = 0
    cdef float chance_2 = 0
    cdef float chance_2_random = 0
    cdef float chancerdom = 0
    cdef float relinkrandom = 0

    if par.state >= 2:
        return
    if par.links_activnum >= max_link:
        return
    if par.sys.links_active == 0:
        return

    if parothers_id == -1:
        # kd_tree.KDTree_rnn_query(data.kdtree, &fakepar[0], par.loc, par.sys.link_length)
        # neighbours = fakepar[0].neighbours
        neighbours = par.neighbours
        neighboursnum = par.neighboursnum
    else:
        neighbours = <int *>malloc(1 * cython.sizeof(int))
        neighbours[0] = parothers_id
        neighboursnum = 1

    for ii in xrange(neighboursnum):
        if par.links_activnum >= max_link:
            break
        if parothers_id == -1:
            par2 = &data.parlist[neighbours[ii]]
            tension = (par.sys.link_tension + par2.sys.link_tension) / 2
        else:
            par2 = &data.parlist[neighbours[0]]
            tension = (par.sys.link_tension + par2.sys.link_tension) / 2
        if par.id != par2.id:
            # utils.arraysearch(par2.id, par.link_with, par.link_withnum)

            if utils.arraysearch(par.id,par2.link_with,par2.link_withnum) == -1 and \
                    par2.state <= 1 and par.state <= 1:

            #if par not in par2.link_with and par2.state <= 1 \
            #   and par.state <= 1:

                link.start = par.id
                link.end = par2.id

                if par.sys.use_link_friction_tex:
                    friction_1 = par.sys.link_friction_tex[par.id]
                    friction_1_random = 0.0
                else:
                    friction_1 = par.sys.link_friction
                    friction_1_random = par.sys.link_frictionrand

                if par2.sys.use_link_friction_tex:
                    friction_2 = par2.sys.link_friction_tex[par2.id]
                    friction_2_random = 0.0
                else:
                    friction_2 = par2.sys.link_friction
                    friction_2_random = par2.sys.link_frictionrand

                frictionrandom = friction_1_random + friction_2_random
                link.friction = ((friction_1 + friction_2) / 2) * ((((rand() / rand_max) * frictionrandom) - (frictionrandom / 2)) + 1)

                if parothers_id == -1 and par.sys.link_group == par2.sys.link_group:
                    if par.sys.id != par2.sys.id:
                        if par.sys.other_link_active and par2.sys.other_link_active:
                            create_links = 1
                        else:
                            create_links = 0
                    else:
                        create_links = 1

                    if create_links == 1:
                        # link tension
                        if par.sys.use_link_tension_tex:
                            tension_1 = par.sys.link_tension_tex[par.id]
                            tension_1_random = 0.0
                        else:
                            tension_1 = par.sys.link_tension
                            tension_1_random = par.sys.link_tensionrand

                        if par2.sys.use_link_tension_tex:
                            tension_2 = par2.sys.link_tension_tex[par2.id]
                            tension_2_random = 0.0
                        else:
                            tension_2 = par2.sys.link_tension
                            tension_2_random = par2.sys.link_tensionrand

                        tensionrandom = tension_1_random + tension_2_random
                        tension = ((tension_1 + tension_2) / 2) * ((((rand() / rand_max) * tensionrandom) - (tensionrandom / 2)) + 1)

                        # link length
                        link.lenght = ((mol_math.square_dist(par.loc,par2.loc,3))**0.5) * tension

                        # link stiffness
                        if par.sys.use_link_stiff_tex:
                            link_stiff_1 = par.sys.link_stiff_tex[par.id]
                            stiffrandom_1 = 0.0
                        else:
                            link_stiff_1 = par.sys.link_stiff
                            stiffrandom_1 = par.sys.link_stiffrand

                        if par.sys.use_link_estiff_tex:
                            link_estiff_1 = par.sys.link_estiff_tex[par.id]
                            estiffrandom_1 = 0.0
                        else:
                            link_estiff_1 = par.sys.link_estiff
                            estiffrandom_1 = par.sys.link_estiffrand

                        if par2.sys.use_link_stiff_tex:
                            link_stiff_2 = par2.sys.link_stiff_tex[par2.id]
                            stiffrandom_2 = 0.0
                        else:
                            link_stiff_2 = par2.sys.link_stiff
                            stiffrandom_2 = par2.sys.link_stiffrand

                        if par2.sys.use_link_estiff_tex:
                            link_estiff_2 = par2.sys.link_estiff_tex[par2.id]
                            estiffrandom_2 = 0.0
                        else:
                            link_estiff_2 = par2.sys.link_estiff
                            estiffrandom_2 = par2.sys.link_estiffrand

                        stiffrandom = stiffrandom_1 + stiffrandom_2
                        estiffrandom = estiffrandom_1 + estiffrandom_2
                        link.stiffness = ((link_stiff_1 + link_stiff_2) / 2) * ((((rand() / rand_max) * stiffrandom) - (stiffrandom / 2)) + 1)
                        link.estiffness = ((link_estiff_1 + link_estiff_2) / 2) * ((((rand() / rand_max) * estiffrandom) - (estiffrandom / 2)) + 1)

                        # link exponent
                        link.exponent = abs(int((par.sys.link_stiffexp + par2.sys.link_stiffexp) / 2))
                        link.eexponent = abs(int((par.sys.link_estiffexp + par2.sys.link_estiffexp) / 2))

                        # link damping
                        if par.sys.use_link_damp_tex:
                            damp_1 = par.sys.link_damp_tex[par.id]
                            damp_1_random = 0.0
                        else:
                            damp_1 = par.sys.link_damp
                            damp_1_random = par.sys.link_damprand

                        if par.sys.use_link_edamp_tex:
                            edamp_1 = par.sys.link_edamp_tex[par.id]
                            edamp_1_random = 0.0
                        else:
                            edamp_1 = par.sys.link_edamp
                            edamp_1_random = par.sys.link_edamprand

                        if par2.sys.use_link_damp_tex:
                            damp_2 = par2.sys.link_damp_tex[par2.id]
                            damp_2_random = 0.0
                        else:
                            damp_2 = par2.sys.link_damp
                            damp_2_random = par2.sys.link_damprand

                        if par2.sys.use_link_edamp_tex:
                            edamp_2 = par2.sys.link_edamp_tex[par2.id]
                            edamp_2_random = 0.0
                        else:
                            edamp_2 = par2.sys.link_edamp
                            edamp_2_random = par2.sys.link_edamprand

                        damprandom = damp_1_random + damp_2_random
                        edamprandom = edamp_1_random + edamp_2_random
                        link.damping = ((damp_1 + damp_2) / 2) * ((((rand() / rand_max) * damprandom) - (damprandom / 2)) + 1)
                        link.edamping = ((edamp_1 + edamp_2) / 2) * ((((rand() / rand_max) * edamprandom) - (edamprandom / 2)) + 1)

                        # link broken
                        if par.sys.use_link_broken_tex:
                            broken_1 = par.sys.link_broken_tex[par.id]
                            broken_1_random = 0.0
                        else:
                            broken_1 = par.sys.link_broken
                            broken_1_random = par.sys.link_brokenrand

                        if par.sys.use_link_ebroken_tex:
                            ebroken_1 = par.sys.link_ebroken_tex[par.id]
                            ebroken_1_random = 0.0
                        else:
                            ebroken_1 = par.sys.link_ebroken
                            ebroken_1_random = par.sys.link_ebrokenrand

                        if par2.sys.use_link_broken_tex:
                            broken_2 = par2.sys.link_broken_tex[par2.id]
                            broken_2_random = 0.0
                        else:
                            broken_2 = par2.sys.link_broken
                            broken_2_random = par2.sys.link_brokenrand

                        if par2.sys.use_link_ebroken_tex:
                            ebroken_2 = par2.sys.link_ebroken_tex[par2.id]
                            ebroken_2_random = 0.0
                        else:
                            ebroken_2 = par2.sys.link_ebroken
                            ebroken_2_random = par2.sys.link_ebrokenrand

                        brokrandom = broken_1_random + broken_2_random
                        ebrokrandom = ebroken_1_random + ebroken_2_random
                        link.broken = ((broken_1 + broken_2) / 2) * ((((rand() / rand_max) * brokrandom) - (brokrandom  / 2)) + 1)
                        link.ebroken = ((ebroken_1 + ebroken_2) / 2) * ((((rand() / rand_max) * ebrokrandom) - (ebrokrandom  / 2)) + 1)

                        par.links[par.links_num] = link[0]
                        par.links_num += 1
                        par.links_activnum += 1
                        par.links = <types.Links *>realloc(par.links,(par.links_num + 2) * cython.sizeof(types.Links))

                        par.link_with[par.link_withnum] = par2.id
                        par.link_withnum += 1

                        par.link_with = <int *>realloc(par.link_with,(par.link_withnum + 2) * cython.sizeof(int))

                        par2.link_with[par2.link_withnum] = par.id
                        par2.link_withnum += 1

                        par2.link_with = <int *>realloc(par2.link_with,(par2.link_withnum + 2) * cython.sizeof(int))
                        data.newlinks += 1
                        # free(link)

                if parothers_id != -1 and par.sys.relink_group == par2.sys.relink_group:

                    # relink chance
                    if par.sys.use_relink_chance_tex:
                        chance_1 = par.sys.relink_chance_tex[par.id]
                        chance_1_random = 0.0
                    else:
                        chance_1 = par.sys.relink_chance
                        chance_1_random = par.sys.relink_chancerand

                    if par2.sys.use_relink_chance_tex:
                        chance_2 = par2.sys.relink_chance_tex[par2.id]
                        chance_2_random = 0.0
                    else:
                        chance_2 = par2.sys.relink_chance
                        chance_2_random = par2.sys.relink_chancerand

                    chancerdom = chance_1_random + chance_2_random
                    relinkrandom = (rand() / rand_max)

                    if relinkrandom <= ((chance_1 + chance_2) / 2) * ((((rand() / rand_max) * chancerdom) - (chancerdom / 2)) + 1):

                        # relink tension
                        if par.sys.use_relink_tension_tex:
                            tension_1 = par.sys.relink_tension_tex[par.id]
                            tension_1_random = 0.0
                        else:
                            tension_1 = par.sys.relink_tension
                            tension_1_random = par.sys.relink_tensionrand

                        if par2.sys.use_relink_tension_tex:
                            tension_2 = par2.sys.relink_tension_tex[par2.id]
                            tension_2_random = 0.0
                        else:
                            tension_2 = par2.sys.relink_tension
                            tension_2_random = par2.sys.relink_tensionrand

                        tensionrandom = tension_1_random + tension_2_random
                        tension = ((tension_1 + tension_2) / 2) * ((((rand() / rand_max) * tensionrandom) - (tensionrandom / 2)) + 1)

                        # relink length
                        link.lenght = ((mol_math.square_dist(par.loc, par2.loc, 3)) ** 0.5) * tension

                        # relink stiffness
                        if par.sys.use_relink_stiff_tex:
                            stiff_1 = par.sys.relink_stiff_tex[par.id]
                            stiff_1_random = 0.0
                        else:
                            stiff_1 = par.sys.relink_stiff
                            stiff_1_random = par.sys.relink_stiffrand

                        if par.sys.use_relink_estiff_tex:
                            estiff_1 = par.sys.relink_estiff_tex[par.id]
                            estiff_1_random = 0.0
                        else:
                            estiff_1 = par.sys.relink_estiff
                            estiff_1_random = par.sys.relink_estiffrand

                        if par2.sys.use_relink_stiff_tex:
                            stiff_2 = par2.sys.relink_stiff_tex[par2.id]
                            stiff_2_random = 0.0
                        else:
                            stiff_2 = par2.sys.relink_stiff
                            stiff_2_random = par2.sys.relink_stiffrand

                        if par2.sys.use_relink_estiff_tex:
                            estiff_2 = par2.sys.relink_estiff_tex[par2.id]
                            estiff_2_random = 0.0
                        else:
                            estiff_2 = par2.sys.relink_estiff
                            estiff_2_random = par2.sys.relink_estiffrand

                        stiffrandom = stiff_1_random + stiff_2_random
                        estiffrandom = estiff_1_random + estiff_2_random
                        link.stiffness = ((stiff_1 + stiff_2) / 2) * ((((rand() / rand_max) * stiffrandom) - (stiffrandom / 2)) + 1)
                        link.estiffness = ((estiff_1 + estiff_2) / 2) * ((((rand() / rand_max) * estiffrandom) - (estiffrandom / 2)) + 1)

                        # relink exponent
                        link.exponent = abs(int((par.sys.relink_stiffexp + par2.sys.relink_stiffexp) / 2))
                        link.eexponent = abs(int((par.sys.relink_estiffexp + par2.sys.relink_estiffexp) / 2))

                        # relink damping
                        if par.sys.use_relink_damp_tex:
                            damp_1 = par.sys.relink_damp_tex[par.id]
                            damp_1_random = 0.0
                        else:
                            damp_1 = par.sys.relink_damp
                            damp_1_random = par.sys.relink_damprand

                        if par.sys.use_relink_edamp_tex:
                            edamp_1 = par.sys.relink_edamp_tex[par.id]
                            edamp_1_random = 0.0
                        else:
                            edamp_1 = par.sys.relink_edamp
                            edamp_1_random = par.sys.relink_edamprand

                        if par2.sys.use_relink_damp_tex:
                            damp_2 = par2.sys.relink_damp_tex[par2.id]
                            damp_2_random = 0.0
                        else:
                            damp_2 = par2.sys.relink_damp
                            damp_2_random = par2.sys.relink_damprand

                        if par2.sys.use_relink_edamp_tex:
                            edamp_2 = par2.sys.relink_edamp_tex[par2.id]
                            edamp_2_random = 0.0
                        else:
                            edamp_2 = par2.sys.relink_edamp
                            edamp_2_random = par2.sys.relink_edamprand

                        damprandom = damp_1_random + damp_2_random
                        edamprandom = edamp_1_random + edamp_2_random
                        link.damping = ((damp_1 + damp_2) / 2) * ((((rand() / rand_max) * damprandom) - (damprandom / 2)) + 1)
                        link.edamping = ((edamp_1 + edamp_2) / 2) * ((((rand() / rand_max) * edamprandom) - (edamprandom / 2)) + 1)

                        # relink broken
                        if par.sys.use_relink_broken_tex:
                            broken_1 = par.sys.relink_broken_tex[par.id]
                            broken_1_random = 0.0
                        else:
                            broken_1 = par.sys.relink_broken
                            broken_1_random = par.sys.relink_brokenrand

                        if par.sys.use_relink_ebroken_tex:
                            ebroken_1 = par.sys.relink_ebroken_tex[par.id]
                            ebroken_1_random = 0.0
                        else:
                            ebroken_1 = par.sys.relink_ebroken
                            ebroken_1_random = par.sys.relink_ebrokenrand

                        if par2.sys.use_relink_broken_tex:
                            broken_2 = par2.sys.relink_broken_tex[par2.id]
                            broken_2_random = 0.0
                        else:
                            broken_2 = par2.sys.relink_broken
                            broken_2_random = par2.sys.relink_brokenrand

                        if par2.sys.use_relink_ebroken_tex:
                            ebroken_2 = par2.sys.relink_ebroken_tex[par2.id]
                            ebroken_2_random = 0.0
                        else:
                            ebroken_2 = par2.sys.relink_ebroken
                            ebroken_2_random = par2.sys.relink_ebrokenrand

                        brokrandom = broken_1_random + broken_2_random
                        ebrokrandom = ebroken_1_random + ebroken_2_random
                        link.broken = ((broken_1 + broken_2) / 2) * ((((rand() / rand_max) * brokrandom) - (brokrandom  / 2)) + 1)
                        link.ebroken = ((ebroken_1 + ebroken_2) / 2) * ((((rand() / rand_max) * ebrokrandom) - (ebrokrandom  / 2)) + 1)

                        par.links[par.links_num] = link[0]
                        par.links_num += 1
                        par.links_activnum += 1
                        par.links = <types.Links *>realloc(par.links,(par.links_num + 1) * cython.sizeof(types.Links))
                        par.link_with[par.link_withnum] = par2.id
                        par.link_withnum += 1
                        par.link_with = <int *>realloc(par.link_with,(par.link_withnum + 1) * cython.sizeof(int))
                        par2.link_with[par2.link_withnum] = par.id
                        par2.link_withnum += 1
                        par2.link_with = <int *>realloc(par2.link_with,(par2.link_withnum + 1) * cython.sizeof(int))
                        data.newlinks += 1
                        # free(link)

    # free(neighbours)
    free(fakepar)
    free(link)
    # free(par)
    # free(par2)


cdef void solve_link(types.Particle *par)nogil:
    cdef int i = 0
    cdef float stiff = 0
    cdef float damping = 0
    cdef float timestep = 0
    cdef float exp = 0
    cdef types.Particle *par1 = NULL
    cdef types.Particle *par2 = NULL
    cdef float *Loc1 = [0, 0, 0]
    cdef float *Loc2 = [0, 0, 0]
    cdef float *V1 = [0, 0, 0]
    cdef float *V2 = [0, 0, 0]
    cdef float LengthX = 0
    cdef float LengthY = 0
    cdef float LengthZ = 0
    cdef float Length = 0
    cdef float Vx = 0
    cdef float Vy = 0
    cdef float Vz = 0
    cdef float V = 0
    cdef float ForceSpring = 0
    cdef float ForceDamper = 0
    cdef float ForceX = 0
    cdef float ForceY = 0
    cdef float ForceZ = 0
    cdef float *Force1 = [0, 0, 0]
    cdef float *Force2 = [0, 0, 0]
    cdef float ratio1 = 0
    cdef float ratio2 = 0
    cdef int parsearch = 0
    cdef int par2search = 0
    cdef float *normal1 = [0, 0, 0]
    cdef float *normal2 = [0, 0, 0]
    cdef float factor1 = 0
    cdef float factor2 = 0
    cdef float friction1 = 0
    cdef float friction2 = 0
    cdef float *ypar1_vel = [0, 0, 0]
    cdef float *xpar1_vel = [0, 0, 0]
    cdef float *ypar2_vel = [0, 0, 0]
    cdef float *xpar2_vel = [0, 0, 0]
    # broken_links = []
    if  par.state >= 2:
        return
    for i in xrange(par.links_num):
        if par.links[i].start != -1:
            par1 = &data.parlist[par.links[i].start]
            par2 = &data.parlist[par.links[i].end]
            Loc1[0] = par1.loc[0]
            Loc1[1] = par1.loc[1]
            Loc1[2] = par1.loc[2]
            Loc2[0] = par2.loc[0]
            Loc2[1] = par2.loc[1]
            Loc2[2] = par2.loc[2]
            V1[0] = par1.vel[0]
            V1[1] = par1.vel[1]
            V1[2] = par1.vel[2]
            V2[0] = par2.vel[0]
            V2[1] = par2.vel[1]
            V2[2] = par2.vel[2]
            LengthX = Loc2[0] - Loc1[0]
            LengthY = Loc2[1] - Loc1[1]
            LengthZ = Loc2[2] - Loc1[2]
            Length = (LengthX ** 2 + LengthY ** 2 + LengthZ ** 2) ** (0.5)
            if par.links[i].lenght != Length and Length != 0:
                if par.links[i].lenght > Length:
                    stiff = par.links[i].stiffness * data.deltatime
                    damping = par.links[i].damping
                    exp = par.links[i].exponent
                if par.links[i].lenght < Length:
                    stiff = par.links[i].estiffness * data.deltatime
                    damping = par.links[i].edamping
                    exp = par.links[i].eexponent
                Vx = V2[0] - V1[0]
                Vy = V2[1] - V1[1]
                Vz = V2[2] - V1[2]
                V = (Vx * LengthX + Vy * LengthY + Vz * LengthZ) / Length
                ForceSpring = ((Length - par.links[i].lenght) ** (exp)) * stiff
                ForceDamper = damping * V
                ForceX = (ForceSpring + ForceDamper) * LengthX / Length
                ForceY = (ForceSpring + ForceDamper) * LengthY / Length
                ForceZ = (ForceSpring + ForceDamper) * LengthZ / Length
                Force1[0] = ForceX
                Force1[1] = ForceY
                Force1[2] = ForceZ
                Force2[0] = -ForceX
                Force2[1] = -ForceY
                Force2[2] = -ForceZ
                ratio1 = (par2.mass/(par1.mass + par2.mass))
                ratio2 = (par1.mass/(par1.mass + par2.mass))

                if par1.state == 3: #dead particle, correct velocity ratio of alive partner
                    ratio1 = 0
                    ratio2 = 1
                elif par2.state == 3:
                    ratio1 = 1
                    ratio2 = 0

                par1.vel[0] += Force1[0] * ratio1
                par1.vel[1] += Force1[1] * ratio1
                par1.vel[2] += Force1[2] * ratio1
                par2.vel[0] += Force2[0] * ratio2
                par2.vel[1] += Force2[1] * ratio2
                par2.vel[2] += Force2[2] * ratio2

                normal1[0] = LengthX / Length
                normal1[1] = LengthY / Length
                normal1[2] = LengthZ / Length
                normal2[0] = normal1[0] * -1
                normal2[1] = normal1[1] * -1
                normal2[2] = normal1[2] * -1

                factor1 = mol_math.dot_product(par1.vel, normal1)

                ypar1_vel[0] = factor1 * normal1[0]
                ypar1_vel[1] = factor1 * normal1[1]
                ypar1_vel[2] = factor1 * normal1[2]
                xpar1_vel[0] = par1.vel[0] - ypar1_vel[0]
                xpar1_vel[1] = par1.vel[1] - ypar1_vel[1]
                xpar1_vel[2] = par1.vel[2] - ypar1_vel[2]

                factor2 = mol_math.dot_product(par2.vel, normal2)

                ypar2_vel[0] = factor2 * normal2[0]
                ypar2_vel[1] = factor2 * normal2[1]
                ypar2_vel[2] = factor2 * normal2[2]
                xpar2_vel[0] = par2.vel[0] - ypar2_vel[0]
                xpar2_vel[1] = par2.vel[1] - ypar2_vel[1]
                xpar2_vel[2] = par2.vel[2] - ypar2_vel[2]

                friction1 = 1 - ((par.links[i].friction) * ratio1)
                friction2 = 1 - ((par.links[i].friction) * ratio2)

                par1.vel[0] = ypar1_vel[0] + ((xpar1_vel[0] * friction1) + \
                    (xpar2_vel[0] * ( 1 - friction1)))

                par1.vel[1] = ypar1_vel[1] + ((xpar1_vel[1] * friction1) + \
                    (xpar2_vel[1] * ( 1 - friction1)))

                par1.vel[2] = ypar1_vel[2] + ((xpar1_vel[2] * friction1) + \
                    (xpar2_vel[2] * ( 1 - friction1)))

                par2.vel[0] = ypar2_vel[0] + ((xpar2_vel[0] * friction2) + \
                    (xpar1_vel[0] * ( 1 - friction2)))

                par2.vel[1] = ypar2_vel[1] + ((xpar2_vel[1] * friction2) + \
                    (xpar1_vel[1] * ( 1 - friction2)))

                par2.vel[2] = ypar2_vel[2] + ((xpar2_vel[2] * friction2) + \
                    (xpar1_vel[2] * ( 1 - friction2)))

                if Length > (par.links[i].lenght * (1 + par.links[i].ebroken)) \
                or Length < (par.links[i].lenght  * (1 - par.links[i].broken)):

                    par.links[i].start = -1
                    par.links_activnum -= 1
                    data.deadlinks[threadid()] += 1

                    parsearch = utils.arraysearch(
                        par2.id,
                        par.link_with,
                        par.link_withnum
                    )

                    if parsearch != -1:
                        par.link_with[parsearch] = -1

                    par2search = utils.arraysearch(
                        par.id,
                        par2.link_with,
                        par2.link_withnum
                    )

                    if par2search != -1:
                        par2.link_with[par2search] = -1

                    # broken_links.append(link)
                    # if par2 in par1.link_with:
                        # par1.link_with.remove(par2)
                    # if par1 in par2.link_with:
                        # par2.link_with.remove(par1)

    # par.links = list(set(par.links) - set(broken_links))
    # free(par1)
    # free(par2)
