import bpy
import math
import os

# Cartella di output dei file GLB
OUTPUT_DIR = r"C:\Users\giand\Documents\GitHub\app_magneti_flutter\assets\models\steps"
os.makedirs(OUTPUT_DIR, exist_ok=True)

# Dimensione base di una piastrella (1 unità Blender = 1 tile)
S = 1.0
# Spessore di ogni pannello
T = 0.05

# ── COLORI ────────────────────────────────────────────────────────────────────
# Ogni tile_id ha un colore RGBA (0.0–1.0).
# is_new=True  → opacità 0.85 (pezzo nuovo, evidenziato)
# is_new=False → opacità 0.35 (pezzo già posato, semitrasparente)
COLORS = {
    # piastrelle standard
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
    # castle special
    'quarter_circle_castle':      (0.85, 0.50, 0.98, 1),  # viola chiaro
    'drawbridge':                 (0.55, 0.35, 0.17, 1),  # marrone
    'spiral_staircase':           (0.91, 0.63, 0.75, 1),  # rosa antico
    'balcony':                    (0.72, 0.52, 0.04, 1),  # oro
    'window_castle':              (0.61, 0.35, 0.71, 1),  # viola scuro
}


# ── UTILITY ───────────────────────────────────────────────────────────────────

def clear_scene():
    """Pulisce tutta la scena Blender (oggetti, materiali, mesh)."""
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.delete()
    for m in list(bpy.data.materials): bpy.data.materials.remove(m)
    for m in list(bpy.data.meshes):    bpy.data.meshes.remove(m)


def make_mat(tile_id, is_new):
    """Crea un materiale PBR per il tile, con opacità diversa se nuovo o già posato."""
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
    """Esporta la scena corrente in formato GLB."""
    bpy.ops.export_scene.gltf(filepath=path, export_format='GLB', export_apply=True)


def add_camera(location=(4.5, -4.5, 4.5)):
    """Aggiunge camera e luci per il render della costruzione."""
    bpy.ops.object.camera_add(location=location)
    cam = bpy.context.object
    cam.rotation_euler = (math.radians(58), 0, math.radians(45))
    cam.data.lens = 35
    bpy.context.scene.camera = cam
    # luce solare principale
    bpy.ops.object.light_add(type='SUN', location=(3, -3, 8))
    sun = bpy.context.object
    sun.data.energy = 3
    sun.rotation_euler = (math.radians(45), 0, math.radians(30))
    # luce di area per ammorbidire le ombre
    bpy.ops.object.light_add(type='AREA', location=(-3, 3, 5))
    bpy.context.object.data.energy = 500
    bpy.context.object.data.size   = 4


# ── PRIMITIVE STANDARD ────────────────────────────────────────────────────────

def add_quad_wall(name, cx, cy, cz, face, is_new, tile_id='quadrato_grande'):
    """Pannello quadrato (S×S×T) orientato su una delle 4 facce cardinali."""
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


def add_rect_wall(name, cx, cy, cz, face, is_new, tile_id='rettangolo', w=1.0, h=0.5):
    """Pannello rettangolare (w×h×T) orientato su una delle 4 facce cardinali."""
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


def add_tri_roof_pyramid(side, base_z, apex_z, is_new, tile_id='triangolo_isoscele_grande'):
    """Triangolo isoscele a tetto, orientato verso uno dei 4 lati cardinali."""
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


# ── PRIMITIVE CASTLE ──────────────────────────────────────────────────────────

def add_quarter_circle(name, cx, cy, cz, corner, is_new, tile_id='quarter_circle_castle', segments=16):
    """
    Quarto di cerchio (pannello curvo S×S×T) collocato in uno degli angoli:
      corner: 'NW', 'NE', 'SE', 'SW'
    Utile per archi, torri cilindriche e cupole.
    """
    r = S / 2   # raggio = metà tile
    t = T / 2
    # angoli di inizio e fine in base all'angolo del castello
    angoli = {'NW': (math.pi/2, math.pi),
               'NE': (0,         math.pi/2),
               'SE': (-math.pi/2, 0),
               'SW': (-math.pi,  -math.pi/2)}
    a0, a1 = angoli.get(corner, (0, math.pi/2))
    step = (a1 - a0) / segments
    # vertici fronte (z fissa)
    front = [(r*math.cos(a0+i*step), r*math.sin(a0+i*step), -t) for i in range(segments+1)]
    back  = [(x, y, t) for x, y, _ in front]
    verts = front + back
    n = segments + 1
    faces = []
    # faccia frontale (fan)
    for i in range(segments):
        faces.append([i, i+1, n+i+1, n+i])
    mesh = bpy.data.meshes.new(name)
    mesh.from_pydata(verts, [], faces)
    mesh.update()
    obj = bpy.data.objects.new(name, mesh)
    bpy.context.collection.objects.link(obj)
    obj.location = (cx, cy, cz)
    obj.data.materials.append(make_mat(tile_id, is_new))
    return obj


def add_drawbridge(name, cx, cy, cz, face, is_new, tile_id='drawbridge'):
    """
    Ponte levatoio: pannello quadrato S×S×T con arco passante centrale.
    L'arco occupa la metà inferiore (come una porta ad arco medievale).
    Costruito con due montanti laterali + traversa superiore.
    """
    h  = S / 2
    t  = T / 2
    aw = 0.3    # metà larghezza arco
    ah = 0.55   # altezza arco dal basso

    # montante sinistro, montante destro, traversa superiore
    def box(x0, x1, z0, z1):
        return [
            (x0, -t, z0), (x1, -t, z0), (x1, -t, z1), (x0, -t, z1),
            (x0,  t, z0), (x1,  t, z0), (x1,  t, z1), (x0,  t, z1),
        ]

    def add_box_part(suffix, verts_box):
        fs = [[0,1,2,3],[7,6,5,4],[0,4,5,1],[1,5,6,2],[2,6,7,3],[3,7,4,0]]
        m = bpy.data.meshes.new(f"{name}_{suffix}")
        m.from_pydata(verts_box, [], fs)
        m.update()
        o = bpy.data.objects.new(f"{name}_{suffix}", m)
        bpy.context.collection.objects.link(o)
        o.location = (cx, cy, cz)
        o.data.materials.append(make_mat(tile_id, is_new))
        return o

    # montante sinistro: da -h a -aw, da -h a h (altezza intera)
    add_box_part('L', box(-h, -aw, -h, h))
    # montante destro: da +aw a +h
    add_box_part('R', box( aw,  h, -h, h))
    # traversa superiore: da -aw a +aw, dalla cima arco in su
    add_box_part('T', box(-aw, aw, ah - h, h))

    # ruota se necessario per orientamento faccia
    if face in ('E', 'W'):
        for suffix in ('L', 'R', 'T'):
            obj = bpy.data.objects[f"{name}_{suffix}"]
            obj.rotation_euler = (0, 0, math.radians(90))


def add_spiral_staircase(name, cx, cy, cz, is_new, tile_id='spiral_staircase',
                          n_steps=8, radius=0.35, rise_per_step=0.12):
    """
    Scala a spirale: gradini a ventaglio che salgono attorno all'asse Z.
    n_steps    = numero di gradini
    radius     = raggio esterno
    rise_per_step = alzata di ogni gradino
    """
    angle_per_step = math.radians(360 / n_steps)
    for i in range(n_steps):
        angle = i * angle_per_step
        z_base = i * rise_per_step
        z_top  = z_base + rise_per_step * 0.8   # lascia un piccolo gap
        # vertici del gradino (settore circolare piatto)
        a0 = angle
        a1 = angle + angle_per_step * 0.9
        inner = 0.08  # raggio interno (perno)
        verts = [
            (inner*math.cos(a0), inner*math.sin(a0), z_base),
            (radius*math.cos(a0), radius*math.sin(a0), z_base),
            (radius*math.cos(a1), radius*math.sin(a1), z_base),
            (inner*math.cos(a1), inner*math.sin(a1), z_base),
            (inner*math.cos(a0), inner*math.sin(a0), z_top),
            (radius*math.cos(a0), radius*math.sin(a0), z_top),
            (radius*math.cos(a1), radius*math.sin(a1), z_top),
            (inner*math.cos(a1), inner*math.sin(a1), z_top),
        ]
        faces = [[0,1,2,3],[7,6,5,4],[0,4,5,1],[1,5,6,2],[2,6,7,3],[3,7,4,0]]
        step_name = f"{name}_step{i}"
        mesh = bpy.data.meshes.new(step_name)
        mesh.from_pydata(verts, [], faces)
        mesh.update()
        obj = bpy.data.objects.new(step_name, mesh)
        bpy.context.collection.objects.link(obj)
        obj.location = (cx, cy, cz)
        obj.data.materials.append(make_mat(tile_id, is_new))


def add_balcony(name, cx, cy, cz, face, is_new, tile_id='balcony'):
    """
    Balcone: piano orizzontale (S × S/3 × T) che sporge dalla parete,
    con parapetto su tre lati (N, E, W rispetto al balcone stesso).
    """
    t   = T / 2
    pw  = S          # larghezza balcone
    pd  = S / 3      # profondità sporgenza
    ph  = 0.15       # altezza parapetto

    # piano del balcone (lastra orizzontale)
    bpy.ops.mesh.primitive_cube_add(size=1)
    piano = bpy.context.object
    piano.name = f"{name}_floor"
    piano.scale = (pw/2, pd/2, t)
    bpy.ops.object.transform_apply(scale=True)
    piano.location = (cx, cy - pd/2 if face == 'N' else cy + pd/2, cz)
    piano.data.materials.clear()
    piano.data.materials.append(make_mat(tile_id, is_new))

    # parapetto frontale
    bpy.ops.mesh.primitive_cube_add(size=1)
    front = bpy.context.object
    front.name = f"{name}_front"
    front.scale = (pw/2, t, ph/2)
    bpy.ops.object.transform_apply(scale=True)
    front.location = (cx, cy - pd if face == 'N' else cy + pd, cz + ph/2)
    front.data.materials.clear()
    front.data.materials.append(make_mat(tile_id, is_new))

    # parapetti laterali (sinistra e destra)
    for side_x in (-pw/2, pw/2):
        bpy.ops.mesh.primitive_cube_add(size=1)
        lat = bpy.context.object
        lat.name = f"{name}_side_{side_x}"
        lat.scale = (t, pd/2, ph/2)
        bpy.ops.object.transform_apply(scale=True)
        lat.location = (cx + side_x, cy - pd/2 if face == 'N' else cy + pd/2, cz + ph/2)
        lat.data.materials.clear()
        lat.data.materials.append(make_mat(tile_id, is_new))


def add_window_castle(name, cx, cy, cz, face, is_new, tile_id='window_castle'):
    """
    Finestra castle: pannello quadrato S×S×T con apertura ogivale (a sesto acuto).
    Costruito con due montanti + traversa + arco ogivale approssimato.
    L'apertura ogivale lascia uno spazio passante al centro.
    """
    h  = S / 2
    t  = T / 2
    ww = 0.25   # metà larghezza finestra
    wh = 0.55   # altezza totale finestra dal basso
    arch_h = 0.15  # altezza extra della punta ogivale

    def box(x0, x1, z0, z1):
        return [
            (x0, -t, z0), (x1, -t, z0), (x1, -t, z1), (x0, -t, z1),
            (x0,  t, z0), (x1,  t, z0), (x1,  t, z1), (x0,  t, z1),
        ]

    def add_box_part(suffix, verts_box):
        fs = [[0,1,2,3],[7,6,5,4],[0,4,5,1],[1,5,6,2],[2,6,7,3],[3,7,4,0]]
        m = bpy.data.meshes.new(f"{name}_{suffix}")
        m.from_pydata(verts_box, [], fs)
        m.update()
        o = bpy.data.objects.new(f"{name}_{suffix}", m)
        bpy.context.collection.objects.link(o)
        o.location = (cx, cy, cz)
        o.data.materials.append(make_mat(tile_id, is_new))
        return o

    # montante sinistro
    add_box_part('L', box(-h, -ww, -h, h))
    # montante destro
    add_box_part('R', box( ww,  h, -h, h))
    # parte bassa sotto la finestra
    add_box_part('B', box(-ww, ww, -h, -h + (h - wh)))
    # traversa sopra l'apertura rettangolare
    add_box_part('T', box(-ww, ww, -h + wh, h))

    # ruota se necessario per orientamento faccia
    if face in ('E', 'W'):
        for suffix in ('L', 'R', 'B', 'T'):
            obj = bpy.data.objects[f"{name}_{suffix}"]
            obj.rotation_euler = (0, 0, math.radians(90))


# ── DISPATCHER ────────────────────────────────────────────────────────────────

def draw_step(pieces):
    """
    Disegna tutti i pezzi di uno step.
    Ogni item è una tupla: (tipo, ...parametri...)
    Tipi supportati:
      'quad'         → pannello quadrato standard
      'quad_tile'    → pannello quadrato con tile_id personalizzato
      'tri_pyramid'  → triangolo tetto a piramide
      'rect'         → pannello rettangolare
      'quarter'      → quarto di cerchio castle
      'drawbridge'   → ponte levatoio castle
      'staircase'    → scala a spirale castle
      'balcony'      → balcone castle
      'window_castle'→ finestra ogivale castle
    """
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
        elif kind == 'quarter':
            _, cx, cy, cz, corner, is_new = item
            add_quarter_circle(f"qc_{corner}_{cz}", cx, cy, cz, corner, is_new)
        elif kind == 'drawbridge':
            _, face, cx, cy, cz, is_new = item
            add_drawbridge(f"db_{face}_{cz}", cx, cy, cz, face, is_new)
        elif kind == 'staircase':
            _, cx, cy, cz, is_new = item
            add_spiral_staircase(f"sc_{cx}_{cz}", cx, cy, cz, is_new)
        elif kind == 'balcony':
            _, face, cx, cy, cz, is_new = item
            add_balcony(f"bl_{face}_{cz}", cx, cy, cz, face, is_new)
        elif kind == 'window_castle':
            _, face, cx, cy, cz, is_new = item
            add_window_castle(f"wc_{face}_{cz}", cx, cy, cz, face, is_new)


# ── HELPER: pannelli già posati / nuovi ───────────────────────────────────────

def quad_old(face, piano):
    """Pannello quadrato già posato (semitrasparente) al piano indicato."""
    cz = (piano - 1) * S + S / 2
    offsets = {'N': (0, -0.5), 'S': (0, 0.5), 'E': (0.5, 0), 'W': (-0.5, 0)}
    cx, cy = offsets[face]
    return ('quad', face, cx, cy, cz, False)


def quad_new(face, piano):
    """Pannello quadrato nuovo (evidenziato) al piano indicato."""
    cz = (piano - 1) * S + S / 2
    offsets = {'N': (0, -0.5), 'S': (0, 0.5), 'E': (0.5, 0), 'W': (-0.5, 0)}
    cx, cy = offsets[face]
    return ('quad', face, cx, cy, cz, True)


# ── COSTRUZIONE: TORRE ────────────────────────────────────────────────────────
# 3 piani di 4 muri + tetto a piramide 4 falde = 16 step
# step 1 = intro (vuoto), step 18 = finale (vuoto)

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

torre_steps.append([])  # step finale vuoto


# ── ESECUZIONE ────────────────────────────────────────────────────────────────
# Le costruzioni con is3d=False usano la guida 2D flat: nessun GLB necessario.
# Aggiungere qui ogni nuova costruzione 3D con la relativa posizione camera.
CONSTRUCTIONS = {
    'torre': (torre_steps, (4.5, -4.5, 4.5)),
    # 'castello': (castello_steps, (6.0, -6.0, 5.0)),  # esempio future
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
for cid, (steps, _) in CONSTRUCTIONS.items():
    print(f"  {cid}: {len(steps)} step")
