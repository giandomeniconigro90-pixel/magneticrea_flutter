import bpy
import math
import os

OUTPUT_DIR = r"C:\Users\giand\Documents\GitHub\app_magneti_flutter\assets\models\steps"
os.makedirs(OUTPUT_DIR, exist_ok=True)

S = 1.0
T = 0.05

COLORS = {
    'quadrato_grande':            (1.0,  0.42, 0.42, 1),  # rosso
    'quadrato_piccolo':           (1.0,  0.62, 0.26, 1),  # arancio
    'rettangolo':                 (0.15, 0.82, 0.80, 1),  # verde acqua
    'triangolo_equilatero':       (0.13, 0.75, 0.42, 1),  # verde
    'triangolo_isoscele_grande':  (0.27, 0.67, 0.95, 1),  # blu
    'triangolo_isoscele_piccolo': (0.17, 0.80, 0.73, 1),  # celeste
    'triangolo_rettangolo':       (0.65, 0.37, 0.92, 1),  # viola
    'rombo':                      (0.99, 0.36, 0.40, 1),  # rosso acceso
    'pentagono':                  (0.99, 0.59, 0.27, 1),  # arancio
    'esagono':                    (0.29, 0.48, 0.93, 1),  # blu
    'porta':                      (0.91, 0.26, 0.58, 1),  # rosa
    'finestra':                   (0.91, 0.26, 0.58, 1),  # rosa
    'base_macchina':              (0.27, 0.67, 0.95, 1),  # azzurro
}

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

# ── PRIMITIVE 3D ──────────────────────────────────────────────────

def add_quad_wall(name, cx, cy, cz, face, is_new, tile_id='quadrato_grande'):
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
    faces = [[0,1,2,3],[7,6,5,4],[0,4,5,1],[1,5,6,2],[2,6,7,3],[3,7,4,0]]
    mesh = bpy.data.meshes.new(name)
    mesh.from_pydata(verts, [], faces)
    mesh.update()
    obj = bpy.data.objects.new(name, mesh)
    bpy.context.collection.objects.link(obj)
    obj.location = (cx, cy, cz)
    obj.data.materials.append(make_mat(tile_id, is_new))
    return obj

def add_tri_roof_pyramid(side, base_z, apex_z, is_new, tile_id='triangolo_isoscele_grande'):
    t = T / 2
    if side == 'N':
        verts = [(-0.5,-0.5-t,base_z),(0.5,-0.5-t,base_z),(0.0,-t,apex_z),
                 (-0.5,-0.5+t,base_z),(0.5,-0.5+t,base_z),(0.0, t,apex_z)]
    elif side == 'S':
        verts = [(-0.5,0.5+t,base_z),(0.5,0.5+t,base_z),(0.0, t,apex_z),
                 (-0.5,0.5-t,base_z),(0.5,0.5-t,base_z),(0.0,-t,apex_z)]
    elif side == 'E':
        verts = [(0.5+t,-0.5,base_z),(0.5+t,0.5,base_z),( t,0.0,apex_z),
                 (0.5-t,-0.5,base_z),(0.5-t,0.5,base_z),(-t,0.0,apex_z)]
    elif side == 'W':
        verts = [(-0.5-t,-0.5,base_z),(-0.5-t,0.5,base_z),(-t,0.0,apex_z),
                 (-0.5+t,-0.5,base_z),(-0.5+t,0.5,base_z),( t,0.0,apex_z)]
    faces = [[0,1,2],[5,4,3],[0,3,4,1],[1,4,5,2],[2,5,3,0]]
    mesh = bpy.data.meshes.new(f"tri_{side}")
    mesh.from_pydata(verts, [], faces)
    mesh.update()
    obj = bpy.data.objects.new(f"tri_{side}", mesh)
    bpy.context.collection.objects.link(obj)
    obj.data.materials.append(make_mat(tile_id, is_new))
    return obj

def add_rect_wall(name, cx, cy, cz, face, is_new, tile_id='rettangolo', w=1.0, h=0.5):
    """Pannello rettangolare (larghezza w, altezza h)."""
    hw = w / 2
    hh = h / 2
    t  = T / 2
    if face in ('N', 'S'):
        verts = [
            (-hw, -t, -hh), ( hw, -t, -hh), ( hw, -t,  hh), (-hw, -t,  hh),
            (-hw,  t, -hh), ( hw,  t, -hh), ( hw,  t,  hh), (-hw,  t,  hh),
        ]
    else:
        verts = [
            (-t, -hw, -hh), (-t,  hw, -hh), (-t,  hw,  hh), (-t, -hw,  hh),
            ( t, -hw, -hh), ( t,  hw, -hh), ( t,  hw,  hh), ( t, -hw,  hh),
        ]
    faces = [[0,1,2,3],[7,6,5,4],[0,4,5,1],[1,5,6,2],[2,6,7,3],[3,7,4,0]]
    mesh = bpy.data.meshes.new(name)
    mesh.from_pydata(verts, [], faces)
    mesh.update()
    obj = bpy.data.objects.new(name, mesh)
    bpy.context.collection.objects.link(obj)
    obj.location = (cx, cy, cz)
    obj.data.materials.append(make_mat(tile_id, is_new))
    return obj

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

def draw_step(pieces):
    for item in pieces:
        kind = item[0]
        if kind == 'quad':
            _, face, cx, cy, cz, is_new = item
            add_quad_wall(f"q_{face}_{cx}_{cz}", cx, cy, cz, face, is_new)
        elif kind == 'quad_tile':
            _, face, cx, cy, cz, is_new, tile_id = item
            add_quad_wall(f"q_{face}_{cx}_{cz}", cx, cy, cz, face, is_new, tile_id)
        elif kind == 'tri_pyramid':
            _, side, base_z, apex_z, is_new = item
            add_tri_roof_pyramid(side, base_z, apex_z, is_new)
        elif kind == 'rect':
            _, face, cx, cy, cz, is_new, tile_id, w, h = item
            add_rect_wall(f"r_{face}_{cx}_{cz}", cx, cy, cz, face, is_new, tile_id, w, h)

# ── HELPER: pannello singolo già posato (semitrasparente) ───────────────
def quad_old(face, piano):
    cz = (piano - 1) * S + S / 2
    offsets = {'N': (0, -0.5), 'S': (0, 0.5), 'E': (0.5, 0), 'W': (-0.5, 0)}
    cx, cy = offsets[face]
    return ('quad', face, cx, cy, cz, False)

def quad_new(face, piano):
    cz = (piano - 1) * S + S / 2
    offsets = {'N': (0, -0.5), 'S': (0, 0.5), 'E': (0.5, 0), 'W': (-0.5, 0)}
    cx, cy = offsets[face]
    return ('quad', face, cx, cy, cz, True)

# ── TORRE: 16 step (1 pannello per volta) + intro + finale = 18 GLB ──────
# step1=intro, step2..13=muri (3 piani x 4), step14..17=tetto, step18=finale

torre_steps = [[]]

for piano in range(1, 4):
    already = [quad_old(f, p) for p in range(1, piano) for f in ['N','S','E','W']]
    for i, face_new in enumerate(['N','S','E','W']):
        done_this = [quad_old(f, piano) for f in ['N','S','E','W'][:i]]
        step = already + done_this + [quad_new(face_new, piano)]
        torre_steps.append(step)

base_z = 3.0
apex_z = 3.9
tutto_muri = [quad_old(f, p) for p in range(1, 4) for f in ['N','S','E','W']]
tetto_sides = ['N','S','E','W']
for i, side_new in enumerate(tetto_sides):
    done_tetto = [('tri_pyramid', s, base_z, apex_z, False) for s in tetto_sides[:i]]
    step = tutto_muri + done_tetto + [('tri_pyramid', side_new, base_z, apex_z, True)]
    torre_steps.append(step)

torre_steps.append([])

# ── ESECUZIONE ──────────────────────────────────────────────────
# NOTA: le costruzioni is3d=false usano la guida 2D flat — nessun GLB necessario.
CONSTRUCTIONS = {
    'torre': (torre_steps, (4.5, -4.5, 4.5)),
}

total = sum(len(s) for s, _ in CONSTRUCTIONS.values())
done  = 0

for cid, (steps, cam_loc) in CONSTRUCTIONS.items():
    for idx, pieces in enumerate(steps):
        clear_scene()
        if pieces:
            draw_step(pieces)
            add_camera(cam_loc)
        fname = f"{cid}_step{idx+1}.glb"
        fpath = os.path.join(OUTPUT_DIR, fname)
        export_glb(fpath)
        done += 1
        print(f"[{done}/{total}] {fname} ✓")

print(f"\n✅ {done} file .glb generati in:\n{OUTPUT_DIR}")
print(f"  torre: {len(torre_steps)} step")
