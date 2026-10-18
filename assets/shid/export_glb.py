import os

import bpy

blend_path = bpy.data.filepath
out_path = os.path.splitext(blend_path)[0] + ".glb"

bpy.ops.export_scene.gltf(
    filepath=out_path,
    export_format="GLB",
    use_visible=True,
    use_renderable=True,
    export_apply=True,
)

print(f"Exported {blend_path} -> {out_path}")
