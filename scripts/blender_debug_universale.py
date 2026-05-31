import bpy

print("\n" + "="*70)
print("DEBUG UNIVERSALE - TUTTI GLI OGGETTI IN SCENA")
print("="*70)

for obj in sorted(bpy.context.scene.objects, key=lambda o: o.name):
    if obj.type != 'MESH':
        continue
    wv = [obj.matrix_world @ v.co for v in obj.data.vertices]
    xs = [v.x for v in wv]
    ys = [v.y for v in wv]
    zs = [v.z for v in wv]
    cx = (min(xs)+max(xs))/2
    cy = (min(ys)+max(ys))/2
    cz = (min(zs)+max(zs))/2
    print(f"[{obj.name:<20}]  "
          f"X:{min(xs):+.3f}->{max(xs):+.3f} (c:{cx:+.3f})  "
          f"Y:{min(ys):+.3f}->{max(ys):+.3f} (c:{cy:+.3f})  "
          f"Z:{min(zs):+.3f}->{max(zs):+.3f} (c:{cz:+.3f})")

print("="*70)
print(f"Totale oggetti mesh: {sum(1 for o in bpy.context.scene.objects if o.type=='MESH')}")
print("="*70)
