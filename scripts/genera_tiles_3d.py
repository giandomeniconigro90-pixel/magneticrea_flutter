import bpy
import math
import os

# Cartella di output dei GLB singoli tile
OUTPUT_DIR = r"C:\Users\giand\Documents\GitHub\app_magneti_flutter\assets\models\tiles"
os.makedirs(OUTPUT_DIR, exist_ok=True)

# Dimensione base tile e spessore pannello
S = 1.0
T = 0.05

# ── COLORI ──────────────────────────────────────────────────────────────────
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


# ── UTILITY ────────────────────────────────────────────────────────────────────

def clear_scene():
    """Pulisce tutta la scena Blender prima di generare un nuovo tile."""
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.delete()
    for m in list(bpy.data.materials): bpy.data.materials.remove(m)
    for m in list(bpy.data.meshes):    bpy.data.meshes.remove(m)


def make_mat(tile_id):
    """Crea il materiale PBR per il tile (sempre opacità piena, is_new=True)."""
    mat = bpy.data.materials.new(f"m_{tile_id}")
    mat.use_nodes = True
    nt = mat.node_tree
    nt.nodes.clear()
    out  = nt.nodes.new('ShaderNodeOutputMaterial')
    bsdf = nt.nodes.new('ShaderNodeBsdfPrincipled')
    nt.links.new(bsdf.outputs['BSDF'], out.inputs['Surface'])
    c = COLORS.get(tile_id, (0.8, 0.8, 0.8, 1))
    bsdf.inputs['Base Color'].default_value = c
    bsdf.inputs['Roughness'].default_value  = 0.2
    bsdf.inputs['Alpha'].default_value      = 1.0  # GLB singolo: sempre opaco
    mat.blend_method = 'OPAQUE'
    return mat


def add_camera_tile():
    """Camera isometrica leggera per visualizzare un singolo tile."""
    bpy.ops.object.camera_add(location=(2.0, -2.0, 2.0))
    cam = bpy.context.object
    cam.rotation_euler = (math.radians(54), 0, math.radians(45))
    cam.data.lens = 50
    bpy.context.scene.camera = cam
    # luce solare
    bpy.ops.object.light_add(type='SUN', location=(2, -2, 4))
    sun = bpy.context.object
    sun.data.energy = 3
    sun.rotation_euler = (math.radians(45), 0, math.radians(30))
    # luce di riempimento
    bpy.ops.object.light_add(type='AREA', location=(-1, 1, 2))
    bpy.context.object.data.energy = 200
    bpy.context.object.data.size   = 2


def export_glb(tile_id):
    """Esporta il tile corrente come GLB in assets/models/tiles/{tile_id}.glb"""
    path = os.path.join(OUTPUT_DIR, f"{tile_id}.glb")
    bpy.ops.export_scene.gltf(filepath=path, export_format='GLB', export_apply=True)
    return path


# ── GENERATORI SINGOLO TILE ────────────────────────────────────────────────────
# Ogni funzione genera la mesh del singolo pezzo centrata nell'origine.

def gen_quadrato(tile_id, w=1.0, h=1.0):
    """Pannello quadrato o rettangolare (fronte N)."""
    hw, hh, t = w/2, h/2, T/2
    verts = [
        (-hw, -t, -hh), ( hw, -t, -hh), ( hw, -t,  hh), (-hw, -t,  hh),
        (-hw,  t, -hh), ( hw,  t, -hh), ( hw,  t,  hh), (-hw,  t,  hh),
    ]
    faces = [[0,1,2,3],[7,6,5,4],[0,4,5,1],[1,5,6,2],[2,6,7,3],[3,7,4,0]]
    mesh = bpy.data.meshes.new(tile_id)
    mesh.from_pydata(verts, [], faces)
    mesh.update()
    obj = bpy.data.objects.new(tile_id, mesh)
    bpy.context.collection.objects.link(obj)
    obj.data.materials.append(make_mat(tile_id))


def gen_triangolo_equilatero(tile_id):
    """Triangolo equilatero piatto (pannello sottile T)."""
    r = S / math.sqrt(3)  # raggio circumscritto
    t = T / 2
    verts_f = [(r*math.cos(math.radians(90+i*120)),
                -t,
                r*math.sin(math.radians(90+i*120))) for i in range(3)]
    verts_b = [(x, t, z) for x, _, z in verts_f]
    verts = verts_f + verts_b
    faces = [[0,1,2],[5,4,3],[0,3,4,1],[1,4,5,2],[2,5,3,0]]
    mesh = bpy.data.meshes.new(tile_id)
    mesh.from_pydata(verts, [], faces)
    mesh.update()
    obj = bpy.data.objects.new(tile_id, mesh)
    bpy.context.collection.objects.link(obj)
    obj.data.materials.append(make_mat(tile_id))


def gen_triangolo_isoscele(tile_id, base=1.0, altezza=1.0):
    """Triangolo isoscele (grande o piccolo) con base orizzontale."""
    hb, t = base/2, T/2
    verts_f = [(-hb, -t, 0), (hb, -t, 0), (0, -t, altezza)]
    verts_b = [(x, t, z) for x, _, z in verts_f]
    verts = verts_f + verts_b
    faces = [[0,1,2],[5,4,3],[0,3,4,1],[1,4,5,2],[2,5,3,0]]
    mesh = bpy.data.meshes.new(tile_id)
    mesh.from_pydata(verts, [], faces)
    mesh.update()
    obj = bpy.data.objects.new(tile_id, mesh)
    bpy.context.collection.objects.link(obj)
    obj.data.materials.append(make_mat(tile_id))


def gen_triangolo_rettangolo(tile_id):
    """Triangolo rettangolo con cateti S e S."""
    t = T / 2
    verts_f = [(0, -t, 0), (S, -t, 0), (0, -t, S)]
    verts_b = [(x, t, z) for x, _, z in verts_f]
    verts = verts_f + verts_b
    # trasla per centrare nell'origine
    cx = S / 3
    cz = S / 3
    verts = [(x - cx, y, z - cz) for x, y, z in verts]
    faces = [[0,1,2],[5,4,3],[0,3,4,1],[1,4,5,2],[2,5,3,0]]
    mesh = bpy.data.meshes.new(tile_id)
    mesh.from_pydata(verts, [], faces)
    mesh.update()
    obj = bpy.data.objects.new(tile_id, mesh)
    bpy.context.collection.objects.link(obj)
    obj.data.materials.append(make_mat(tile_id))


def gen_rombo(tile_id):
    """Rombo (quadrato ruotato 45°)."""
    h, t = S / 2, T / 2
    verts_f = [(0, -t, -h), (h, -t, 0), (0, -t, h), (-h, -t, 0)]
    verts_b = [(x, t, z) for x, _, z in verts_f]
    verts = verts_f + verts_b
    faces = [[0,1,2,3],[7,6,5,4],[0,4,5,1],[1,5,6,2],[2,6,7,3],[3,7,4,0]]
    mesh = bpy.data.meshes.new(tile_id)
    mesh.from_pydata(verts, [], faces)
    mesh.update()
    obj = bpy.data.objects.new(tile_id, mesh)
    bpy.context.collection.objects.link(obj)
    obj.data.materials.append(make_mat(tile_id))


def gen_pentagono(tile_id):
    """Pentagono regolare."""
    t = T / 2
    r = S / (2 * math.sin(math.pi / 5))
    verts_f = [(r*math.cos(math.radians(90+i*72)), -t,
                r*math.sin(math.radians(90+i*72))) for i in range(5)]
    verts_b = [(x, t, z) for x, _, z in verts_f]
    verts = verts_f + verts_b
    n = 5
    faces = [list(range(n)), list(range(2*n-1, n-1, -1))]
    for i in range(n):
        faces.append([i, (i+1)%n, (i+1)%n + n, i + n])
    mesh = bpy.data.meshes.new(tile_id)
    mesh.from_pydata(verts, [], faces)
    mesh.update()
    obj = bpy.data.objects.new(tile_id, mesh)
    bpy.context.collection.objects.link(obj)
    obj.data.materials.append(make_mat(tile_id))


def gen_esagono(tile_id):
    """Esagono regolare."""
    t = T / 2
    r = S / (2 * math.sin(math.pi / 6))  # = S
    verts_f = [(r*math.cos(math.radians(i*60)), -t,
                r*math.sin(math.radians(i*60))) for i in range(6)]
    verts_b = [(x, t, z) for x, _, z in verts_f]
    verts = verts_f + verts_b
    n = 6
    faces = [list(range(n)), list(range(2*n-1, n-1, -1))]
    for i in range(n):
        faces.append([i, (i+1)%n, (i+1)%n + n, i + n])
    mesh = bpy.data.meshes.new(tile_id)
    mesh.from_pydata(verts, [], faces)
    mesh.update()
    obj = bpy.data.objects.new(tile_id, mesh)
    bpy.context.collection.objects.link(obj)
    obj.data.materials.append(make_mat(tile_id))


def gen_porta(tile_id):
    """
    Porta: pannello quadrato con arco passante nella metà inferiore.
    Costruito con montante sinistro + montante destro + traversa superiore.
    """
    h, t = S/2, T/2
    aw = 0.28   # metà larghezza arco
    ah = 0.55   # altezza arco dal basso

    def box_part(suffix, x0, x1, z0, z1):
        verts = [
            (x0,-t,z0),(x1,-t,z0),(x1,-t,z1),(x0,-t,z1),
            (x0, t,z0),(x1, t,z0),(x1, t,z1),(x0, t,z1),
        ]
        fs = [[0,1,2,3],[7,6,5,4],[0,4,5,1],[1,5,6,2],[2,6,7,3],[3,7,4,0]]
        m = bpy.data.meshes.new(f"{tile_id}_{suffix}")
        m.from_pydata(verts, [], fs)
        m.update()
        o = bpy.data.objects.new(f"{tile_id}_{suffix}", m)
        bpy.context.collection.objects.link(o)
        o.data.materials.append(make_mat(tile_id))

    box_part('L', -h,  -aw, -h, h)   # montante sinistro
    box_part('R',  aw,   h, -h, h)   # montante destro
    box_part('T', -aw,  aw, ah - h, h)  # traversa superiore


def gen_finestra(tile_id):
    """
    Finestra standard: pannello con griglia 2×2 passante al centro.
    Costruito con 4 bordi + barra centrale orizzontale + barra verticale.
    """
    h, t = S/2, T/2
    bw = 0.12  # spessore bordo
    bar = 0.05 # spessore barra centrale

    def box_part(suffix, x0, x1, z0, z1):
        verts = [
            (x0,-t,z0),(x1,-t,z0),(x1,-t,z1),(x0,-t,z1),
            (x0, t,z0),(x1, t,z0),(x1, t,z1),(x0, t,z1),
        ]
        fs = [[0,1,2,3],[7,6,5,4],[0,4,5,1],[1,5,6,2],[2,6,7,3],[3,7,4,0]]
        m = bpy.data.meshes.new(f"{tile_id}_{suffix}")
        m.from_pydata(verts, [], fs)
        m.update()
        o = bpy.data.objects.new(f"{tile_id}_{suffix}", m)
        bpy.context.collection.objects.link(o)
        o.data.materials.append(make_mat(tile_id))

    box_part('left',   -h, -h+bw, -h, h)          # bordo sinistro
    box_part('right',  h-bw,  h,  -h, h)          # bordo destro
    box_part('top',    -h+bw, h-bw, h-bw, h)      # bordo superiore
    box_part('bottom', -h+bw, h-bw, -h, -h+bw)    # bordo inferiore
    box_part('hbar',   -h+bw, h-bw, -bar, bar)    # barra orizzontale centrale
    box_part('vbar',   -bar,  bar,  -h+bw, h-bw)  # barra verticale centrale


def gen_base_macchina(tile_id):
    """Base macchina: piano orizzontale con 4 ruote agli angoli."""
    # piano
    bpy.ops.mesh.primitive_cube_add(size=1)
    piano = bpy.context.object
    piano.name = f"{tile_id}_body"
    piano.scale = (S/2, S/3, T*2)
    bpy.ops.object.transform_apply(scale=True)
    piano.data.materials.append(make_mat(tile_id))
    # 4 ruote
    ruota_r = 0.12
    ruota_w = 0.06
    posizioni = [(-S/2+0.15, -S/3-ruota_w/2, -T),
                 ( S/2-0.15, -S/3-ruota_w/2, -T),
                 (-S/2+0.15,  S/3+ruota_w/2, -T),
                 ( S/2-0.15,  S/3+ruota_w/2, -T)]
    for i, (rx, ry, rz) in enumerate(posizioni):
        bpy.ops.mesh.primitive_cylinder_add(radius=ruota_r, depth=ruota_w,
                                             location=(rx, ry, rz))
        ruota = bpy.context.object
        ruota.name = f"{tile_id}_wheel{i}"
        ruota.rotation_euler = (math.radians(90), 0, 0)
        ruota.data.materials.append(make_mat(tile_id))


def gen_quarter_circle(tile_id, segments=24):
    """Quarto di cerchio (pannello curvo S×S×T)."""
    r, t = S/2, T/2
    verts_f = [(r*math.cos(math.radians(i*90/segments)),
                -t,
                r*math.sin(math.radians(i*90/segments))) for i in range(segments+1)]
    verts_b = [(x, t, z) for x, _, z in verts_f]
    verts = verts_f + verts_b
    n = segments + 1
    faces = [[i, i+1, i+1+n, i+n] for i in range(segments)]
    mesh = bpy.data.meshes.new(tile_id)
    mesh.from_pydata(verts, [], faces)
    mesh.update()
    obj = bpy.data.objects.new(tile_id, mesh)
    bpy.context.collection.objects.link(obj)
    obj.data.materials.append(make_mat(tile_id))


def gen_drawbridge(tile_id):
    """Ponte levatoio: 2 montanti + traversa superiore (apertura passante)."""
    h, t = S/2, T/2
    aw, ah = 0.3, 0.55

    def box_part(suffix, x0, x1, z0, z1):
        verts = [
            (x0,-t,z0),(x1,-t,z0),(x1,-t,z1),(x0,-t,z1),
            (x0, t,z0),(x1, t,z0),(x1, t,z1),(x0, t,z1),
        ]
        fs = [[0,1,2,3],[7,6,5,4],[0,4,5,1],[1,5,6,2],[2,6,7,3],[3,7,4,0]]
        m = bpy.data.meshes.new(f"{tile_id}_{suffix}")
        m.from_pydata(verts, [], fs)
        m.update()
        o = bpy.data.objects.new(f"{tile_id}_{suffix}", m)
        bpy.context.collection.objects.link(o)
        o.data.materials.append(make_mat(tile_id))

    box_part('L', -h, -aw, -h,  h)
    box_part('R',  aw,  h, -h,  h)
    box_part('T', -aw, aw, ah - h, h)


def gen_spiral_staircase(tile_id, n_steps=8, radius=0.35, rise_per_step=0.12):
    """Scala a spirale con gradini a ventaglio attorno all'asse Z."""
    angle_per_step = math.radians(360 / n_steps)
    inner = 0.08
    for i in range(n_steps):
        angle = i * angle_per_step
        z_base = i * rise_per_step
        z_top  = z_base + rise_per_step * 0.8
        a0, a1 = angle, angle + angle_per_step * 0.9
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
        step_name = f"{tile_id}_step{i}"
        mesh = bpy.data.meshes.new(step_name)
        mesh.from_pydata(verts, [], faces)
        mesh.update()
        obj = bpy.data.objects.new(step_name, mesh)
        bpy.context.collection.objects.link(obj)
        obj.data.materials.append(make_mat(tile_id))


def gen_balcony(tile_id):
    """Balcone: piano orizzontale con parapetto su 3 lati."""
    t   = T / 2
    pw  = S
    pd  = S / 3
    ph  = 0.15

    bpy.ops.mesh.primitive_cube_add(size=1)
    piano = bpy.context.object
    piano.name = f"{tile_id}_floor"
    piano.scale = (pw/2, pd/2, t)
    bpy.ops.object.transform_apply(scale=True)
    piano.location = (0, -pd/2, 0)
    piano.data.materials.append(make_mat(tile_id))

    bpy.ops.mesh.primitive_cube_add(size=1)
    front = bpy.context.object
    front.name = f"{tile_id}_front"
    front.scale = (pw/2, t, ph/2)
    bpy.ops.object.transform_apply(scale=True)
    front.location = (0, -pd, ph/2)
    front.data.materials.append(make_mat(tile_id))

    for side_x in (-pw/2, pw/2):
        bpy.ops.mesh.primitive_cube_add(size=1)
        lat = bpy.context.object
        lat.name = f"{tile_id}_side_{side_x}"
        lat.scale = (t, pd/2, ph/2)
        bpy.ops.object.transform_apply(scale=True)
        lat.location = (side_x, -pd/2, ph/2)
        lat.data.materials.append(make_mat(tile_id))


def gen_window_castle(tile_id):
    """Finestra castle: pannello con apertura ogivale a sesto acuto."""
    h, t = S/2, T/2
    ww, wh = 0.25, 0.55

    def box_part(suffix, x0, x1, z0, z1):
        verts = [
            (x0,-t,z0),(x1,-t,z0),(x1,-t,z1),(x0,-t,z1),
            (x0, t,z0),(x1, t,z0),(x1, t,z1),(x0, t,z1),
        ]
        fs = [[0,1,2,3],[7,6,5,4],[0,4,5,1],[1,5,6,2],[2,6,7,3],[3,7,4,0]]
        m = bpy.data.meshes.new(f"{tile_id}_{suffix}")
        m.from_pydata(verts, [], fs)
        m.update()
        o = bpy.data.objects.new(f"{tile_id}_{suffix}", m)
        bpy.context.collection.objects.link(o)
        o.data.materials.append(make_mat(tile_id))

    box_part('L',  -h,   -ww,  -h,  h)
    box_part('R',   ww,   h,   -h,  h)
    box_part('B',  -ww,   ww,  -h,  -h + (h - wh))
    box_part('T',  -ww,   ww,   -h + wh, h)


# ── REGISTRO TILE ────────────────────────────────────────────────────────────────
# Ogni entry: tile_id -> funzione generatrice (senza argomenti, usa lambda)
TILES = {
    # piastrelle standard
    'quadrato_grande':            lambda: gen_quadrato('quadrato_grande',           w=1.0, h=1.0),
    'quadrato_piccolo':           lambda: gen_quadrato('quadrato_piccolo',          w=0.5, h=0.5),
    'rettangolo':                 lambda: gen_quadrato('rettangolo',                w=1.0, h=0.5),
    'triangolo_equilatero':       lambda: gen_triangolo_equilatero('triangolo_equilatero'),
    'triangolo_isoscele_grande':  lambda: gen_triangolo_isoscele('triangolo_isoscele_grande',  base=1.0, altezza=1.0),
    'triangolo_isoscele_piccolo': lambda: gen_triangolo_isoscele('triangolo_isoscele_piccolo', base=0.5, altezza=0.5),
    'triangolo_rettangolo':       lambda: gen_triangolo_rettangolo('triangolo_rettangolo'),
    'rombo':                      lambda: gen_rombo('rombo'),
    'pentagono':                  lambda: gen_pentagono('pentagono'),
    'esagono':                    lambda: gen_esagono('esagono'),
    'porta':                      lambda: gen_porta('porta'),
    'finestra':                   lambda: gen_finestra('finestra'),
    'base_macchina':              lambda: gen_base_macchina('base_macchina'),
    # castle special
    'quarter_circle_castle':      lambda: gen_quarter_circle('quarter_circle_castle'),
    'drawbridge':                 lambda: gen_drawbridge('drawbridge'),
    'spiral_staircase':           lambda: gen_spiral_staircase('spiral_staircase'),
    'balcony':                    lambda: gen_balcony('balcony'),
    'window_castle':              lambda: gen_window_castle('window_castle'),
}


# ── ESECUZIONE ────────────────────────────────────────────────────────────────
print(f"\n🧱 Generazione GLB singoli tile ({len(TILES)} pezzi)...\n")

for idx, (tile_id, gen_fn) in enumerate(TILES.items(), start=1):
    clear_scene()
    gen_fn()                  # genera la mesh del pezzo
    add_camera_tile()         # aggiunge camera e luci
    path = export_glb(tile_id)
    print(f"[{idx}/{len(TILES)}] {tile_id}.glb ✓")

print(f"\n✅ {len(TILES)} GLB generati in:\n{OUTPUT_DIR}")
print("\nPer usarli nell'app (AR / catalogo 3D):")
print("  assets/models/tiles/{tile_id}.glb")
