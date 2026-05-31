import bpy
import math
import os

# ── CARTELLA OUTPUT ──────────────────────────────────────────────────
OUTPUT_DIR = r"C:\Users\giand\Documents\GitHub\app_magneti_flutter\assets\models\steps"
os.makedirs(OUTPUT_DIR, exist_ok=True)

# ── COLORI PER TILE ──────────────────────────────────────────────────
COLORS = {
    'quadrato_grande':           (1.0,  0.42, 0.42, 1),
    'quadrato_piccolo':          (1.0,  0.62, 0.26, 1),
    'triangolo_equilatero':      (0.13, 0.75, 0.42, 1),
    'triangolo_isoscele_grande': (0.27, 0.67, 0.95, 1),
    'triangolo_isoscele_piccolo':(0.17, 0.80, 0.73, 1),
    'triangolo_rettangolo':      (0.65, 0.37, 0.92, 1),
    'rombo':                     (0.99, 0.36, 0.40, 1),
    'pentagono':                 (0.99, 0.59, 0.27, 1),
    'esagono':                   (0.29, 0.48, 0.93, 1),
}

THICKNESS = 0.08
SCALE     = 1.0

# ── UTILITÀ ──────────────────────────────────────────────────────────

def clear_scene():
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.delete()
    for mat  in list(bpy.data.materials): bpy.data.materials.remove(mat)
    for mesh in list(bpy.data.meshes):    bpy.data.meshes.remove(mesh)

def make_material(name, tile_id, is_new):
    mat = bpy.data.materials.new(name=name)
    mat.use_nodes = True
    nt = mat.node_tree

    # Rimuovi tutti i nodi esistenti e ricrea da zero (compatibile Blender 4/5)
    nt.nodes.clear()

    output = nt.nodes.new('ShaderNodeOutputMaterial')
    bsdf   = nt.nodes.new('ShaderNodeBsdfPrincipled')
    nt.links.new(bsdf.outputs['BSDF'], output.inputs['Surface'])

    color = COLORS.get(tile_id, (0.8, 0.8, 0.8, 1))
    bsdf.inputs['Base Color'].default_value = color
    bsdf.inputs['Roughness'].default_value  = 0.3
    bsdf.inputs['Metallic'].default_value   = 0.1

    if not is_new:
        bsdf.inputs['Alpha'].default_value = 0.45
        mat.blend_method = 'BLEND'

    return mat

def verts_for(tile_id, s):
    h = s * 0.866
    if tile_id in ('quadrato_grande', 'quadrato_piccolo'):
        return [(-s/2,-s/2),(s/2,-s/2),(s/2,s/2),(-s/2,s/2)]
    elif tile_id == 'triangolo_equilatero':
        return [(0, h*2/3),(-s/2,-h/3),(s/2,-h/3)]
    elif tile_id in ('triangolo_isoscele_grande','triangolo_isoscele_piccolo'):
        return [(0, s*0.55),(-s/2,-s*0.45),(s/2,-s*0.45)]
    elif tile_id == 'triangolo_rettangolo':
        return [(-s/2,-s/2),(s/2,-s/2),(-s/2,s/2)]
    elif tile_id == 'rombo':
        return [(0,s/2),(s/2,0),(0,-s/2),(-s/2,0)]
    elif tile_id == 'pentagono':
        return [(math.cos(math.radians(90+i*72))*s/2,
                 math.sin(math.radians(90+i*72))*s/2) for i in range(5)]
    elif tile_id == 'esagono':
        return [(math.cos(math.radians(90+i*60))*s/2,
                 math.sin(math.radians(90+i*60))*s/2) for i in range(6)]
    return [(-s/2,-s/2),(s/2,-s/2),(s/2,s/2),(-s/2,s/2)]

def add_tile(tile_id, x_norm, y_norm, rotation_deg, is_new, area_size=4.0):
    s        = SCALE
    verts2d  = verts_for(tile_id, s)
    cx       = (x_norm - 0.5) * area_size
    cy       = (0.5 - y_norm) * area_size

    verts = [(v[0], v[1], 0)          for v in verts2d] + \
            [(v[0], v[1], THICKNESS)   for v in verts2d]
    n     = len(verts2d)
    faces = [list(range(n))]
    faces += [list(range(n, 2*n))[::-1]]
    for i in range(n):
        faces.append([i, (i+1)%n, n+(i+1)%n, n+i])

    mesh = bpy.data.meshes.new(tile_id)
    mesh.from_pydata(verts, [], faces)
    mesh.update()

    obj = bpy.data.objects.new(tile_id, mesh)
    bpy.context.collection.objects.link(obj)
    obj.location      = (cx, cy, 0)
    obj.rotation_euler= (0, 0, math.radians(rotation_deg or 0))

    mat_name = f"{tile_id}_{'new' if is_new else 'old'}"
    mat = make_material(mat_name, tile_id, is_new)
    obj.data.materials.append(mat)
    return obj

def add_lights_and_camera():
    bpy.ops.object.light_add(type='SUN', location=(2, -2, 5))
    bpy.context.object.data.energy = 3
    bpy.ops.object.light_add(type='AREA', location=(-2, 2, 4))
    bpy.context.object.data.energy = 200
    bpy.ops.object.camera_add(location=(0, -6, 5))
    cam = bpy.context.object
    cam.rotation_euler = (math.radians(55), 0, 0)
    bpy.context.scene.camera = cam

def export_glb(path):
    bpy.ops.export_scene.gltf(
        filepath=path,
        export_format='GLB',
        export_apply=True,
    )

# ── DATI COSTRUZIONI ─────────────────────────────────────────────────
# Formato: lista di passi, ogni passo = lista di tuple
# (tile_id, x_norm, y_norm, rotazione_gradi, is_new)
# is_new=True  → pezzo appena aggiunto (colore pieno)
# is_new=False → pezzo già presente   (semitrasparente)
# Passo con lista vuota [] = intro/finale, genera file GLB vuoto

CONSTRUCTIONS = {
  'casa': [
    [],
    [('quadrato_grande',0.5,0.65,0,True)],
    [('quadrato_grande',0.5,0.65,0,False),('triangolo_isoscele_grande',0.35,0.30,0,True)],
    [('quadrato_grande',0.5,0.65,0,False),('triangolo_isoscele_grande',0.35,0.30,0,False),('triangolo_isoscele_grande',0.65,0.30,0,True)],
  ],
  'pesce': [
    [],
    [('quadrato_piccolo',0.5,0.5,0,True)],
    [('quadrato_piccolo',0.5,0.5,0,False),('rombo',0.75,0.5,0,True)],
    [('quadrato_piccolo',0.5,0.5,0,False),('rombo',0.75,0.5,0,False),('triangolo_equilatero',0.5,0.25,0,True)],
    [('quadrato_piccolo',0.5,0.5,0,False),('rombo',0.75,0.5,0,False),('triangolo_equilatero',0.5,0.25,0,False),('triangolo_equilatero',0.5,0.75,180,True)],
  ],
  'fiore': [
    [],
    [('pentagono',0.5,0.5,0,True)],
    [('pentagono',0.5,0.5,0,False),('triangolo_equilatero',0.5,0.2,0,True)],
    [('pentagono',0.5,0.5,0,False),('triangolo_equilatero',0.5,0.2,0,False),('triangolo_equilatero',0.78,0.65,120,True)],
    [('pentagono',0.5,0.5,0,False),('triangolo_equilatero',0.5,0.2,0,False),('triangolo_equilatero',0.78,0.65,120,False),('triangolo_equilatero',0.22,0.65,240,True)],
  ],
  'stella': [
    [],
    [('esagono',0.5,0.5,0,True)],
    [('esagono',0.5,0.5,0,False),('triangolo_equilatero',0.38,0.22,0,True),('triangolo_equilatero',0.62,0.22,0,True)],
    [('esagono',0.5,0.5,0,False),('triangolo_equilatero',0.38,0.22,0,False),('triangolo_equilatero',0.62,0.22,0,False),('triangolo_equilatero',0.2,0.5,90,True),('triangolo_equilatero',0.8,0.5,270,True)],
    [('esagono',0.5,0.5,0,False),('triangolo_equilatero',0.38,0.22,0,False),('triangolo_equilatero',0.62,0.22,0,False),('triangolo_equilatero',0.2,0.5,90,False),('triangolo_equilatero',0.8,0.5,270,False),('triangolo_equilatero',0.38,0.78,180,True),('triangolo_equilatero',0.62,0.78,180,True)],
  ],
  'farfalla': [
    [],
    [('triangolo_isoscele_piccolo',0.5,0.5,0,True)],
    [('triangolo_isoscele_piccolo',0.5,0.5,0,False),('rombo',0.28,0.28,45,True)],
    [('triangolo_isoscele_piccolo',0.5,0.5,0,False),('rombo',0.28,0.28,45,False),('rombo',0.72,0.28,-45,True)],
    [('triangolo_isoscele_piccolo',0.5,0.5,0,False),('rombo',0.28,0.28,45,False),('rombo',0.72,0.28,-45,False),('triangolo_isoscele_grande',0.28,0.72,150,True)],
    [('triangolo_isoscele_piccolo',0.5,0.5,0,False),('rombo',0.28,0.28,45,False),('rombo',0.72,0.28,-45,False),('triangolo_isoscele_grande',0.28,0.72,150,False),('triangolo_isoscele_grande',0.72,0.72,-150,True)],
  ],
  'razzo': [
    [],
    [('esagono',0.5,0.55,0,True)],
    [('esagono',0.5,0.55,0,False),('esagono',0.5,0.35,0,True)],
    [('esagono',0.5,0.55,0,False),('esagono',0.5,0.35,0,False),('triangolo_isoscele_grande',0.5,0.16,0,True)],
    [('esagono',0.5,0.55,0,False),('esagono',0.5,0.35,0,False),('triangolo_isoscele_grande',0.5,0.16,0,False),('triangolo_rettangolo',0.28,0.68,180,True),('triangolo_rettangolo',0.72,0.68,90,True)],
    [('esagono',0.5,0.55,0,False),('esagono',0.5,0.35,0,False),('triangolo_isoscele_grande',0.5,0.16,0,False),('triangolo_rettangolo',0.28,0.68,180,False),('triangolo_rettangolo',0.72,0.68,90,False),('triangolo_equilatero',0.38,0.82,180,True),('triangolo_equilatero',0.62,0.82,180,True)],
  ],
  'uccello': [
    [],
    [('quadrato_piccolo',0.5,0.52,0,True)],
    [('quadrato_piccolo',0.5,0.52,0,False),('triangolo_isoscele_piccolo',0.65,0.32,0,True)],
    [('quadrato_piccolo',0.5,0.52,0,False),('triangolo_isoscele_piccolo',0.65,0.32,0,False),('triangolo_isoscele_grande',0.22,0.42,90,True)],
    [('quadrato_piccolo',0.5,0.52,0,False),('triangolo_isoscele_piccolo',0.65,0.32,0,False),('triangolo_isoscele_grande',0.22,0.42,90,False),('triangolo_isoscele_grande',0.78,0.42,-90,True)],
    [('quadrato_piccolo',0.5,0.52,0,False),('triangolo_isoscele_piccolo',0.65,0.32,0,False),('triangolo_isoscele_grande',0.22,0.42,90,False),('triangolo_isoscele_grande',0.78,0.42,-90,False),('triangolo_equilatero',0.4,0.75,180,True),('triangolo_equilatero',0.6,0.75,180,True)],
  ],
  'macchina': [
    [],
    [('quadrato_grande',0.5,0.62,0,True)],
    [('quadrato_grande',0.5,0.62,0,False),('quadrato_piccolo',0.5,0.38,0,True)],
    [('quadrato_grande',0.5,0.62,0,False),('quadrato_piccolo',0.5,0.38,0,False),('triangolo_rettangolo',0.3,0.38,270,True),('triangolo_rettangolo',0.7,0.38,180,True)],
    [('quadrato_grande',0.5,0.62,0,False),('quadrato_piccolo',0.5,0.38,0,False),('triangolo_rettangolo',0.3,0.38,270,False),('triangolo_rettangolo',0.7,0.38,180,False),('rombo',0.28,0.82,0,True),('rombo',0.72,0.82,0,True)],
  ],
  'torre': [
    [],
    [('quadrato_grande',0.5,0.75,0,True)],
    [('quadrato_grande',0.5,0.75,0,False),('quadrato_grande',0.5,0.52,0,True)],
    [('quadrato_grande',0.5,0.75,0,False),('quadrato_grande',0.5,0.52,0,False),('quadrato_grande',0.5,0.29,0,True)],
    [('quadrato_grande',0.5,0.75,0,False),('quadrato_grande',0.5,0.52,0,False),('quadrato_grande',0.5,0.29,0,False),('triangolo_equilatero',0.33,0.1,0,True),('triangolo_equilatero',0.67,0.1,0,True)],
    [('quadrato_grande',0.5,0.75,0,False),('quadrato_grande',0.5,0.52,0,False),('quadrato_grande',0.5,0.29,0,False),('triangolo_equilatero',0.33,0.1,0,False),('triangolo_equilatero',0.67,0.1,0,False),('triangolo_isoscele_grande',0.22,0.75,90,True),('triangolo_isoscele_grande',0.78,0.75,-90,True)],
  ],
  'barca': [
    [],
    [('quadrato_grande',0.5,0.7,0,True)],
    [('quadrato_grande',0.5,0.7,0,False),('triangolo_isoscele_grande',0.5,0.38,0,True)],
    [('quadrato_grande',0.5,0.7,0,False),('triangolo_isoscele_grande',0.5,0.38,0,False),('triangolo_rettangolo',0.72,0.5,-90,True)],
    [('quadrato_grande',0.5,0.7,0,False),('triangolo_isoscele_grande',0.5,0.38,0,False),('triangolo_rettangolo',0.72,0.5,-90,False),('rombo',0.72,0.82,0,True)],
  ],
  'albero': [
    [],
    [('quadrato_piccolo',0.5,0.82,0,True)],
    [('quadrato_piccolo',0.5,0.82,0,False),('triangolo_isoscele_grande',0.32,0.62,0,True),('triangolo_isoscele_grande',0.68,0.62,0,True)],
    [('quadrato_piccolo',0.5,0.82,0,False),('triangolo_isoscele_grande',0.32,0.62,0,False),('triangolo_isoscele_grande',0.68,0.62,0,False),('triangolo_equilatero',0.5,0.4,0,True)],
    [('quadrato_piccolo',0.5,0.82,0,False),('triangolo_isoscele_grande',0.32,0.62,0,False),('triangolo_isoscele_grande',0.68,0.62,0,False),('triangolo_equilatero',0.5,0.4,0,False),('triangolo_isoscele_piccolo',0.5,0.2,0,True)],
  ],
  'castello': [
    [],
    [('quadrato_grande',0.5,0.65,0,True)],
    [('quadrato_grande',0.5,0.65,0,False),('quadrato_piccolo',0.22,0.58,0,True),('quadrato_piccolo',0.78,0.58,0,True)],
    [('quadrato_grande',0.5,0.65,0,False),('quadrato_piccolo',0.22,0.58,0,False),('quadrato_piccolo',0.78,0.58,0,False),('quadrato_grande',0.22,0.35,0,True)],
    [('quadrato_grande',0.5,0.65,0,False),('quadrato_piccolo',0.22,0.58,0,False),('quadrato_piccolo',0.78,0.58,0,False),('quadrato_grande',0.22,0.35,0,False),('quadrato_grande',0.78,0.35,0,True)],
    [('quadrato_grande',0.5,0.65,0,False),('quadrato_piccolo',0.22,0.58,0,False),('quadrato_piccolo',0.78,0.58,0,False),('quadrato_grande',0.22,0.35,0,False),('quadrato_grande',0.78,0.35,0,False),('triangolo_isoscele_grande',0.22,0.14,0,True),('triangolo_isoscele_grande',0.78,0.14,0,True)],
    [('quadrato_grande',0.5,0.65,0,False),('quadrato_piccolo',0.22,0.58,0,False),('quadrato_piccolo',0.78,0.58,0,False),('quadrato_grande',0.22,0.35,0,False),('quadrato_grande',0.78,0.35,0,False),('triangolo_isoscele_grande',0.22,0.14,0,False),('triangolo_isoscele_grande',0.78,0.14,0,False),('triangolo_equilatero',0.36,0.46,0,True),('triangolo_equilatero',0.44,0.46,0,True),('triangolo_equilatero',0.56,0.46,0,True),('triangolo_equilatero',0.64,0.46,0,True)],
  ],
  'elicottero': [
    [],
    [('esagono',0.45,0.55,0,True)],
    [('esagono',0.45,0.55,0,False),('quadrato_piccolo',0.72,0.6,0,True)],
    [('esagono',0.45,0.55,0,False),('quadrato_piccolo',0.72,0.6,0,False),('triangolo_isoscele_piccolo',0.88,0.48,-90,True)],
    [('esagono',0.45,0.55,0,False),('quadrato_piccolo',0.72,0.6,0,False),('triangolo_isoscele_piccolo',0.88,0.48,-90,False),('rombo',0.28,0.3,90,True),('rombo',0.52,0.3,90,True)],
    [('esagono',0.45,0.55,0,False),('quadrato_piccolo',0.72,0.6,0,False),('triangolo_isoscele_piccolo',0.88,0.48,-90,False),('rombo',0.28,0.3,90,False),('rombo',0.52,0.3,90,False),('rombo',0.88,0.72,0,True)],
    [('esagono',0.45,0.55,0,False),('quadrato_piccolo',0.72,0.6,0,False),('triangolo_isoscele_piccolo',0.88,0.48,-90,False),('rombo',0.28,0.3,90,False),('rombo',0.52,0.3,90,False),('rombo',0.88,0.72,0,False),('triangolo_rettangolo',0.3,0.78,180,True),('triangolo_rettangolo',0.55,0.78,90,True)],
  ],
  'treno': [
    [],
    [('quadrato_grande',0.28,0.6,0,True)],
    [('quadrato_grande',0.28,0.6,0,False),('quadrato_grande',0.65,0.6,0,True)],
    [('quadrato_grande',0.28,0.6,0,False),('quadrato_grande',0.65,0.6,0,False),('quadrato_piccolo',0.28,0.36,0,True)],
    [('quadrato_grande',0.28,0.6,0,False),('quadrato_grande',0.65,0.6,0,False),('quadrato_piccolo',0.28,0.36,0,False),('esagono',0.1,0.6,0,True)],
    [('quadrato_grande',0.28,0.6,0,False),('quadrato_grande',0.65,0.6,0,False),('quadrato_piccolo',0.28,0.36,0,False),('esagono',0.1,0.6,0,False),('triangolo_rettangolo',0.1,0.38,0,True)],
    [('quadrato_grande',0.28,0.6,0,False),('quadrato_grande',0.65,0.6,0,False),('quadrato_piccolo',0.28,0.36,0,False),('esagono',0.1,0.6,0,False),('triangolo_rettangolo',0.1,0.38,0,False),('rombo',0.15,0.82,0,True),('rombo',0.45,0.82,0,True),('rombo',0.75,0.82,0,True)],
  ],
  'cubo_3d': [
    [],
    [('quadrato_grande',0.5,0.7,0,True)],
    [('quadrato_grande',0.5,0.7,0,False),('quadrato_grande',0.5,0.45,0,True)],
    [('quadrato_grande',0.5,0.7,0,False),('quadrato_grande',0.5,0.45,0,False),('quadrato_grande',0.75,0.45,0,True)],
    [('quadrato_grande',0.5,0.7,0,False),('quadrato_grande',0.5,0.45,0,False),('quadrato_grande',0.75,0.45,0,False),('quadrato_grande',0.25,0.45,0,True)],
    [('quadrato_grande',0.5,0.7,0,False),('quadrato_grande',0.5,0.45,0,False),('quadrato_grande',0.75,0.45,0,False),('quadrato_grande',0.25,0.45,0,False),('quadrato_grande',0.5,0.2,0,True)],
    [('quadrato_grande',0.5,0.7,0,False),('quadrato_grande',0.5,0.45,0,False),('quadrato_grande',0.75,0.45,0,False),('quadrato_grande',0.25,0.45,0,False),('quadrato_grande',0.5,0.2,0,False),('quadrato_grande',0.5,0.1,0,True)],
  ],
}

# ── ESECUZIONE ───────────────────────────────────────────────────────
total = sum(len(steps) for steps in CONSTRUCTIONS.values())
done  = 0

for construction_id, steps in CONSTRUCTIONS.items():
    for step_idx, pieces in enumerate(steps):
        clear_scene()
        if pieces:
            for (tile_id, x, y, rot, is_new) in pieces:
                add_tile(tile_id, x, y, rot, is_new)
            add_lights_and_camera()
        fname = f"{construction_id}_step{step_idx + 1}.glb"
        fpath = os.path.join(OUTPUT_DIR, fname)
        export_glb(fpath)
        done += 1
        print(f"[{done}/{total}] {fname}")

print(f"\n✅ COMPLETATO! {done} file .glb generati in:\n{OUTPUT_DIR}")
