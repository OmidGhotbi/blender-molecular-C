INT_MIN = -2 ** 31
INT_MAX = 2 ** 31 - 1

FLOAT_MIN = -3.402823e+38
FLOAT_MAX = 3.402823e+38

# property_name: (default_value, minimum, maximum)
values = {
    'active': False,
    'bakeuv': False,
    'collision_damp': (0.005, 0.0, 1.0),
    'collision_group': (1, 1, INT_MAX),
    'density': (1000.0, 0.001, FLOAT_MAX),
    'density_active': False,
    'friction': (0.005, 0.0, 1.0),
    'link_broken': (0.5, 0.0, FLOAT_MAX),
    'link_broken_mode': 'CONSTANT',
    'link_broken_samevalue': True,
    'link_brokenrand': (0.0, 0.0, 1.0),
    'link_brokentex': '',
    'link_brokentex_coeff': (1.0, FLOAT_MIN, FLOAT_MAX),
    'link_damp': (1.0, 0.0, 1.0),
    'link_damp_mode': 'CONSTANT',
    'link_damp_samevalue': True,
    'link_damprand': (0.0, 0.0, 1.0),
    'link_damptex': '',
    'link_damptex_coeff': (1.0, FLOAT_MIN, FLOAT_MAX),
    'link_ebroken': (0.5, 0.0, FLOAT_MAX),
    'link_ebrokenrand': (0.0, 0.0, 1.0),
    'link_ebrokentex': '',
    'link_ebrokentex_coeff': (1.0, FLOAT_MIN, FLOAT_MAX),
    'link_edamp': (1.0, 0.0, 1.0),
    'link_edamprand': (0.0, 0.0, 1.0),
    'link_edamptex': '',
    'link_edamptex_coeff': (1.0, FLOAT_MIN, FLOAT_MAX),
    'link_estiff': (1.0, 0.0, 1.0),
    'link_estiffrand': (0.0, 0.0, 1.0),
    'link_estifftex': '',
    'link_estifftex_coeff': (1.0, FLOAT_MIN, FLOAT_MAX),
    'link_friction': (0.005, 0.0, 1.0),
    'link_friction_mode': 'CONSTANT',
    'link_frictionrand': (0.0, 0.0, 1.0),
    'link_frictiontex': '',
    'link_frictiontex_coeff': (1.0, FLOAT_MIN, FLOAT_MAX),
    'link_group': (1, 1, INT_MAX),
    'link_length': (1.0, 0.0, FLOAT_MAX),
    'link_max': (16, 0, INT_MAX),
    'link_rellength': True,
    'link_stiff': (1.0, 0.0, 1.0),
    'link_stiff_mode': 'CONSTANT',
    'link_stiff_samevalue': True,
    'link_stiffrand': (0.0, 0.0, 1.0),
    'link_stifftex': '',
    'link_stifftex_coeff': (1.0, FLOAT_MIN, FLOAT_MAX),
    'links_active': False,
    'matter': -1,
    'other_link_active': False,
    'othercollision_active': False,
    'refresh': True,
    'relink_broken': (0.5, 0.0, FLOAT_MAX),
    'relink_broken_mode': 'CONSTANT',
    'relink_broken_samevalue': True,
    'relink_brokenrand': (0.0, 0.0, 1.0),
    'relink_brokentex': '',
    'relink_brokentex_coeff': (1.0, FLOAT_MIN, FLOAT_MAX),
    'relink_chance': (0.0, 0.0, 100.0),
    'relink_chance_mode': 'CONSTANT',
    'relink_chancerand': (0.0, 0.0, 1.0),
    'relink_chancetex': '',
    'relink_chancetex_coeff': (1.0, FLOAT_MIN, FLOAT_MAX),
    'relink_damp': (1.0, 0.0, 1.0),
    'relink_damp_mode': 'CONSTANT',
    'relink_damp_samevalue': True,
    'relink_damprand': (0.0, 0.0, 1.0),
    'relink_damptex': '',
    'relink_damptex_coeff': (1.0, FLOAT_MIN, FLOAT_MAX),
    'relink_ebroken': (0.5, 0.0, FLOAT_MAX),
    'relink_ebrokenrand': (0.0, 0.0, 1.0),
    'relink_ebrokentex': '',
    'relink_ebrokentex_coeff': (1.0, FLOAT_MIN, FLOAT_MAX),
    'relink_edamp': (1.0, 0.0, 1.0),
    'relink_edamprand': (0.0, 0.0, 1.0),
    'relink_edamptex': '',
    'relink_edamptex_coeff': (1.0, FLOAT_MIN, FLOAT_MAX),
    'relink_estiff': (1.0, 0.0, 1.0),
    'relink_estiffrand': (0.0, 0.0, 1.0),
    'relink_estifftex': '',
    'relink_estifftex_coeff': (1.0, FLOAT_MIN, FLOAT_MAX),
    'relink_friction': (0.005, 0.0, 1.0),
    'relink_friction_mode': 'CONSTANT',
    'relink_frictionrand': (0.0, 0.0, 1.0),
    'relink_frictiontex': '',
    'relink_frictiontex_coeff': (1.0, FLOAT_MIN, FLOAT_MAX),
    'nk_group': (1, 1, INT_MAX),
    'nk_max': (16, 0, INT_MAX),
    'relink_stiff': (1.0, 0.0, 1.0),
    'relink_stiff_mode': 'CONSTANT',
    'relink_stiff_samevalue': True,
    'relink_stiffrand': (0.0, 0.0, 1.0),
    'relink_stifftex': '',
    'relink_stifftex_coeff': (1.0, FLOAT_MIN, FLOAT_MAX),
    'selfcollision_active': False,
    'var1': (1000, 1, INT_MAX),
    'var2': (4, 1, INT_MAX),
    'var3': (1000, 1, INT_MAX)
}
