import bpy
import math
import os

# ── CARTELLA OUTPUT ──────────────────────────────────────────────────
OUTPUT_DIR = r"C:\Users\giand\Documents\GitHub\app_magneti_flutter\assets\models\steps"
os.makedirs(OUTPUT_DIR, exist_ok=True)

S = 1.0   # lato piastrella
T = 0.05  # spessore piastrella

# ── COLORI ───────────────────────────────────────────────────────────
COLORS = {
    'quadrato_grande':           (1.0,  0.42, 0.42, 1),
    'triangolo_isoscele_grande': (0.27, 0.67, 0.95, 1),
}

# ── UTILITÀ ──────────────────────────────────────────────────────────

def clear_scene():
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.delete()
    for m in list(bpy.data.materials): bpy.data.materials.remove(m)
    for m in list(bpy.data.meshes):    bpy.data.meshes.remove(m)

def make_mat(tile_id, is_new):
    mat = bpy.data.materials.new(f"m_{tile_id}_{is_new}")
    mat.use_nodes = True
    nt = mat.node_tree
    nt.nodes.clear()
    out  = nt.nodes.new('ShaderNodeOutputMaterial')
    bsdf = nt.nodes.new('ShaderNodeBsdfPrincipled')
    nt.links.new(bsdf.outputs['BSDF'], out.inputs['Surface'])
    c = COLORS.get(tile_id, (0.8, 0.8, 0.8, 1))
    bsdf.inputs['Base Color'].default_value = c
    bsdf.inputs['Roughness'].default_value  = 0.2
    bsdf.inputs['Alpha'].default_value      = 0.85 if is_new else 0.35
    mat.blend_method = 'BLEND'
    return mat

def export_glb(path):
    bpy.ops.export_scene.gltf(filepath=path, export_format='GLB', export_apply=True)

# ── PRIMITIVE 3D ─────────────────────────────────────────────────────

def add_quad_wall(name, cx, cy, cz, face, is_new):
    """Pannello quadrato in piedi (muro). face: N/S/E/W."""
    h = S / 2
    t = T / 2
    if face in ('N', 'S'):
        verts = [
            (-h, -t, -h), ( h, -t, -h), ( h, -t,  h), (-h, -t,  h),
            (-h,  t, -h), ( h,  t, -h), ( h,  t,  h), (-h,  t,  h),
        ]
    else:
        verts = [
            (-t, -h, -h), (-t,  h, -h), (-t,  h,  h), (-t, -h,  h),
            ( t, -h, -h), ( t,  h, -h), ( t,  h,  h), ( t, -h,  h),
        ]
    faces = [
        [0,1,2,3], [7,6,5,4],
        [0,4,5,1], [1,5,6,2], [2,6,7,3], [3,7,4,0]
    ]
    mesh = bpy.data.meshes.new(name)
    mesh.from_pydata(verts, [], faces)
    mesh.update()
    obj = bpy.data.objects.new(name, mesh)
    bpy.context.collection.objects.link(obj)
    obj.location = (cx, cy, cz)
    obj.data.materials.append(make_mat('quadrato_grande', is_new))
    return obj

def add_tri_roof_pyramid(side, base_z, apex_z, is_new):
    """
    Triangolo tetto piramide (torre).
    Gap realistico alla punta = spessore T delle piastrelle.
    """
    t = T / 2
    if side == 'N':
        verts = [
            (-0.5, -0.5-t, base_z), (0.5, -0.5-t, base_z), (0.0, -t, apex_z),
            (-0.5, -0.5+t, base_z), (0.5, -0.5+t, base_z), (0.0,  t, apex_z),
        ]
    elif side == 'S':
        verts = [
            (-0.5, 0.5+t, base_z), (0.5, 0.5+t, base_z), (0.0,  t, apex_z),
            (-0.5, 0.5-t, base_z), (0.5, 0.5-t, base_z), (0.0, -t, apex_z),
        ]
    elif side == 'E':
        verts = [
            (0.5+t, -0.5, base_z), (0.5+t, 0.5, base_z), ( t, 0.0, apex_z),
            (0.5-t, -0.5, base_z), (0.5-t, 0.5, base_z), (-t, 0.0, apex_z),
        ]
    elif side == 'W':
        verts = [
            (-0.5-t, -0.5, base_z), (-0.5-t, 0.5, base_z), (-t, 0.0, apex_z),
            (-0.5+t, -0.5, base_z), (-0.5+t, 0.5, base_z), ( t, 0.0, apex_z),
        ]
    faces = [[0,1,2],[5,4,3],[0,3,4,1],[1,4,5,2],[2,5,3,0]]
    mesh = bpy.data.meshes.new(f"tri_{side}")
    mesh.from_pydata(verts, [], faces)
    mesh.update()
    obj = bpy.data.objects.new(f"tri_{side}", mesh)
    bpy.context.collection.objects.link(obj)
    obj.data.materials.append(make_mat('triangolo_isoscele_grande', is_new))
    return obj

def add_tri_gable(side, base_z, apex_z, is_new):
    """
    Triangolo frontone casa (lati N/S tetto a 2 falde).
    La punta rimane sul piano verticale del muro (Y costante).
    """
    t = T / 2
    if side == 'N':
        verts = [
            (-0.5, -0.5-t, base_z), (0.5, -0.5-t, base_z), (0.0, -0.5-t, apex_z),
            (-0.5, -0.5+t, base_z), (0.5, -0.5+t, base_z), (0.0, -0.5+t, apex_z),
        ]
    elif side == 'S':
        verts = [
            (-0.5, 0.5+t, base_z), (0.5, 0.5+t, base_z), (0.0, 0.5+t, apex_z),
            (-0.5, 0.5-t, base_z), (0.5, 0.5-t, base_z), (0.0, 0.5-t, apex_z),
        ]
    faces = [[0,1,2],[5,4,3],[0,3,4,1],[1,4,5,2],[2,5,3,0]]
    mesh = bpy.data.meshes.new(f"gable_{side}")
    mesh.from_pydata(verts, [], faces)
    mesh.update()
    obj = bpy.data.objects.new(f"gable_{side}", mesh)
    bpy.context.collection.objects.link(obj)
    obj.data.materials.append(make_mat('triangolo_isoscele_grande', is_new))
    return obj

def add_roof_panel(side, base_z, apex_z, is_new):
    """
    Falda del tetto casa (lati E/W) — pannello quadrato inclinato.
    Va dal bordo del muro (X=±0.5, Z=base_z) al colmo (X=0, Z=apex_z).
    """
    t = T / 2
    if side == 'E':
        verts = [
            ( 0.5, -0.5, base_z), ( 0.5,  0.5, base_z),
            ( t,   0.5, apex_z),  ( t,  -0.5, apex_z),
            (-t,  -0.5, apex_z),  (-t,   0.5, apex_z),
            (-0.5, -0.5, base_z), (-0.5,  0.5, base_z),
        ]
    elif side == 'W':
        verts = [
            (-0.5, -0.5, base_z), (-0.5,  0.5, base_z),
            (-t,   0.5, apex_z),  (-t,  -0.5, apex_z),
            ( t,  -0.5, apex_z),  ( t,   0.5, apex_z),
            ( 0.5, -0.5, base_z), ( 0.5,  0.5, base_z),
        ]
    faces = [
        [0,1,2,3], [7,6,5,4],
        [0,6,7,1], [0,3,4,6],
        [1,7,5,2], [3,2,5,4],
    ]
    mesh = bpy.data.meshes.new(f"roof_{side}")
    mesh.from_pydata(verts, [], faces)
    mesh.update()
    obj = bpy.data.objects.new(f"roof_{side}", mesh)
    bpy.context.collection.objects.link(obj)
    obj.data.materials.append(make_mat('quadrato_grande', is_new))
    return obj

# ── CAMERA & LUCI ────────────────────────────────────────────────────

def add_camera(location=(4.5, -4.5, 4.5)):
    bpy.ops.object.camera_add(location=location)
    cam = bpy.context.object
    cam.rotation_euler = (math.radians(58), 0, math.radians(45))
    cam.data.lens = 35
    bpy.context.scene.camera = cam
    bpy.ops.object.light_add(type='SUN', location=(3, -3, 8))
    sun = bpy.context.object
    sun.data.energy = 3
    sun.rotation_euler = (math.radians(45), 0, math.radians(30))
    bpy.ops.object.light_add(type='AREA', location=(-3, 3, 5))
    bpy.context.object.data.energy = 500
    bpy.context.object.data.size   = 4

# ── COSTRUZIONI ──────────────────────────────────────────────────────
# Ogni costruzione e' una lista di step.
# Ogni step e' una lista di tuple che descrivono i pezzi.
# Formati supportati:
#   ('quad', face, cx, cy, cz, is_new)        → pannello quadrato muro
#   ('tri_pyramid', side, base_z, apex_z, is_new) → triangolo piramide
#   ('tri_gable', side, base_z, apex_z, is_new)   → frontone casa
#   ('roof_panel', side, base_z, apex_z, is_new)  → falda tetto casa

def piano_torre(n, is_new):
    cz = (n - 1) * S + S / 2
    return [
        ('quad', 'N',  0,    -0.5, cz, is_new),
        ('quad', 'S',  0,     0.5, cz, is_new),
        ('quad', 'E',  0.5,   0,   cz, is_new),
        ('quad', 'W', -0.5,   0,   cz, is_new),
    ]

def tetto_piramide(is_new):
    return [
        ('tri_pyramid', 'N', 3.0, 3.9, is_new),
        ('tri_pyramid', 'S', 3.0, 3.9, is_new),
        ('tri_pyramid', 'E', 3.0, 3.9, is_new),
        ('tri_pyramid', 'W', 3.0, 3.9, is_new),
    ]

def muri_casa(is_new):
    cz = S / 2
    return [
        ('quad', 'N',  0,    -0.5, cz, is_new),
        ('quad', 'S',  0,     0.5, cz, is_new),
        ('quad', 'E',  0.5,   0,   cz, is_new),
        ('quad', 'W', -0.5,   0,   cz, is_new),
    ]

def tetto_casa(is_new):
    return [
        ('tri_gable',  'N', 1.0, 1.9, is_new),
        ('tri_gable',  'S', 1.0, 1.9, is_new),
        ('roof_panel', 'E', 1.0, 1.9, is_new),
        ('roof_panel', 'W', 1.0, 1.9, is_new),
    ]

CONSTRUCTIONS = {
    # ── TORRE: 3 piani + tetto piramide ─────────────────────────────
    'torre': [
        [],
        piano_torre(1, True),
        piano_torre(1, False) + piano_torre(2, True),
        piano_torre(1, False) + piano_torre(2, False) + piano_torre(3, True),
        piano_torre(1, False) + piano_torre(2, False) + piano_torre(3, False) + tetto_piramide(True),
    ],
    # ── CASA: 1 piano + tetto a 2 falde ─────────────────────────────
    'casa': [
        [],
        muri_casa(True),
        muri_casa(False) + [('tri_gable', 'N', 1.0, 1.9, True), ('tri_gable', 'S', 1.0, 1.9, True)],
        muri_casa(False) + [('tri_gable', 'N', 1.0, 1.9, False), ('tri_gable', 'S', 1.0, 1.9, False)] + tetto_casa(True)[2:],
        muri_casa(False) + tetto_casa(False),
    ],
}

# ── DRAW ─────────────────────────────────────────────────────────────

def draw_step(pieces):
    for item in pieces:
        kind = item[0]
        if kind == 'quad':
            _, face, cx, cy, cz, is_new = item
            add_quad_wall(f"quad_{face}", cx, cy, cz, face, is_new)
        elif kind == 'tri_pyramid':
            _, side, base_z, apex_z, is_new = item
            add_tri_roof_pyramid(side, base_z, apex_z, is_new)
        elif kind == 'tri_gable':
            _, side, base_z, apex_z, is_new = item
            add_tri_gable(side, base_z, apex_z, is_new)
        elif kind == 'roof_panel':
            _, side, base_z, apex_z, is_new = item
            add_roof_panel(side, base_z, apex_z, is_new)

# ── ESECUZIONE ───────────────────────────────────────────────────────

total = sum(len(steps) for steps in CONSTRUCTIONS.values())
done  = 0

for construction_id, steps in CONSTRUCTIONS.items():
    cam_loc = (4.5, -4.5, 4.5) if construction_id == 'torre' else (3.5, -3.5, 2.8)
    for step_idx, pieces in enumerate(steps):
        clear_scene()
        if pieces:
            draw_step(pieces)
            add_camera(cam_loc)
        fname = f"{construction_id}_step{step_idx + 1}.glb"
        fpath = os.path.join(OUTPUT_DIR, fname)
        export_glb(fpath)
        done += 1
        print(f"[{done}/{total}] {fname} ✓")

print(f"\n✅ COMPLETATO! {done} file .glb generati in:\n{OUTPUT_DIR}")
