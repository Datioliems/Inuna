# Art Bible - Muted Storybook Toon 3D

## Direction

The game uses a muted storybook-anime 3D style: hand-drawn feeling, soft outlines, cel-shaded color bands, low saturation, warm highlights, and readable silhouettes from a third-person camera.

## Character Material Rules

- Animals use flat albedo-like palettes with 3-4 toon bands: shadow, mid, light, warm cream highlight.
- Fur is represented by shape language and color patches, not realistic strand rendering.
- The player dog must be readable from behind through ears, curled tail, body proportions, fur markings, and a small charm/collar.
- NPC animals share one toon material family so dogs, cats, parrots, horses, chickens, and ducks feel part of the same world.

## Blender Lookdev

- Use Eevee for `Shader to RGB` preview.
- Prefer `Diffuse BSDF -> Shader to RGB -> ColorRamp`.
- Set ColorRamp interpolation to `Constant`.
- Use about 4 stops per material.
- Use Object Info random variation gently for plants/props: hue around `0.47-0.53`, saturation around `0.9-1.1`.

## Godot Runtime

- Use `ToonAnimalMaterial` and `ToonWorldMaterial` ShaderMaterials.
- Avoid metallic and noisy PBR.
- Keep roughness high.
- Use inverted-hull or post-process outline; V1 uses inverted-hull outlines.
- Keep highlight color warm and rare.

