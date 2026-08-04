---
name: game-asset-library
description: Local game assets under /Users/phil/Assets for models, textures, sprites, UI, audio, fonts, skyboxes, and prototypes. Use ONLY in the Game Dev agent, proactively before creating placeholders, generating assets, or downloading asset packs, and whenever a request asks to find, choose, import, or use game assets.
compatibility: opencode
metadata:
  scope: game-dev
  asset-root: /Users/phil/Assets
---

# Local Game Asset Library

Use `/Users/phil/Assets` as a read-only source library. Find the smallest suitable
asset set, copy only the required files into the active project, integrate them,
and verify the result in Godot.

## When to Use

- Search this library before creating placeholder visuals or audio, generating
  replacements, or looking for remote asset packs.
- Use it for models, textures, sprites, UI graphics, fonts, sounds, skyboxes,
  prototyping pieces, and environment art.
- Do not replace suitable assets already established in the project.
- If the task explicitly requires original or custom art, use the catalog only
  when it can support that request without changing its intent.

## Source-Library Rules

- Treat `/Users/phil/Assets` as immutable. Never edit, rename, move, or delete
  its files.
- Never make a shipped project depend on an absolute `/Users/phil/Assets/...`
  path. Copy selected source files into the project; do not symlink by default.
- Preserve each pack as a namespace. Never flatten files from different packs,
  and preserve exact relative paths and filename case for material dependencies.
- Use `<set-id>:<basename>` as the stable asset ID when recording a selection,
  for example `castle-kit:tower-square-mid`.
- Read the pack's `License.txt` and retain a namespaced copy with vendored
  assets. Never overwrite an unrelated project license.
- Do not ship either UI Pack TTF without explicit user approval after reviewing
  the embedded-license conflict documented in its guide.

## Discovery Workflow

1. Read `/Users/phil/Assets/ASSET_CATALOG.md` first. Choose candidate packs by
   gameplay role, not by scanning all 11,000-plus files.
2. Read each candidate pack's `ASSET_GUIDE.md`, especially its inventory,
   naming, relationships, coordinates, selection guide, known issues, and
   license sections.
3. Search guide text with `grep` for semantic terms and relationships. Then use
   `glob` inside the candidate pack to resolve exact files for a basename.
4. Choose the semantic basename before choosing an export format, color,
   resolution, or palette variation.
5. Inspect matching `Previews/<basename>.png`, `Preview.png`, or `Sample.png`
   files with the image-capable `read` tool when appearance matters. Compare a
   maximum of three strong candidates rather than dumping a whole pack.
6. Ask one focused question only when the visual choice is consequential and
   the request gives no direction. Otherwise choose the best match and proceed.

If no local asset fits, state the missing need briefly and continue with the
least costly fallback allowed by the request.

## Format Selection

- Prefer GLB for static 3D assets when the pack guide lists no transform defect.
- Follow guide-specific exceptions rather than applying one import preset to
  every pack. In particular, check Factory and Prototype animation workflows,
  Nature normalization, and Coaster or Toy Car GLB root offsets.
- Avoid OBJ for newer model packs unless required and the importer is known to
  handle duplicate faces, vertex-color extensions, and lost hierarchy.
- For palette-based models, copy the format-local `Textures/colormap.png` at
  the exact relative path expected by the model. Select alternate palettes only
  deliberately; they are not assigned automatically.
- For fixed-size UI, choose the appropriate Default or Double PNG. Use SVG when
  scalable source is needed, accounting for the UI Pack's missing `viewBox`.
- Read the relevant guide before assuming an image is tileable, stretchable,
  color-safe, or suitable for nine-slicing.

## Copy and Integrate

1. Follow the project's existing asset and third-party layout. If none exists,
   use `assets/third_party/kenney/<set-id>/` as the destination namespace.
2. Copy only the selected runtime files, their direct dependencies, and the
   pack license. Quote source and destination paths because format directories
   and filenames can contain spaces.
3. Keep dependency paths intact. For example, a model copied from a format root
   alongside `Textures/colormap.png` must retain that same relative layout.
4. Reference copied files with `res://` paths. Never edit generated `.godot/`
   cache or imported-resource files.
5. Add project-owned wrappers separately: scenes, collisions, sockets, LODs,
   navigation, physics, animation, and scripts are generally not supplied.
6. Preserve useful authored origins. Snap modular pieces by documented origins
   and endpoints rather than assuming bounding-box centers.

Do not copy a full pack unless the user requests it or the project's runtime
design demonstrably needs most of that pack.

## Verify

After Godot imports the copied files:

1. Check for missing external textures or importer errors.
2. Open or run the smallest affected scene and verify scale, up axis, origin,
   materials, filtering, transparency, and modular alignment.
3. Run the project entry point when practical and distinguish new failures from
   pre-existing warnings.
4. Report the stable asset IDs, project paths, copied dependencies, authored
   runtime additions, and any unresolved guide warning.
