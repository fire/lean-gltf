# lean-gltf

A small, dependency-free [Lean 4](https://lean-lang.org/) library for building
and serializing [glTF 2.0](https://www.khronos.org/gltf/) 3D assets, including
the binary `.glb` container.

It is a **writer** library: you assemble an in-memory `Document` (scenes,
nodes, meshes, skins, animations, accessors, buffer views, buffers) and emit
either a binary `.glb` or a text `.gltf` file. There is no parser/reader.

## Features

- Pure Lean 4 — no external dependencies beyond the standard library.
- Full glTF 2.0 graph model: `Asset`, `Buffer`, `BufferView`, `Accessor`,
  `Mesh`/`Primitive`, `Skin`, `Node`, `Animation` (channels + samplers),
  `Scene`, and a default PBR `Material`.
- A small hand-rolled JSON encoder with precise float formatting (NaN/inf are
  emitted as `null` per the spec, integer-valued floats render as `123.0`).
- A spec-correct GLB binary serializer (12-byte header + JSON chunk +
  optional little-endian `BIN` chunk, both padded to 4-byte boundaries).
- Optional fields are modeled with `Option` and omitted from the output JSON
  when unset, matching reference exporters.

## Scope

The data model deliberately omits textures, images, samplers, cameras, morph
targets, and extensions. Every primitive shares one default PBR material.

## Build

```sh
lake build
```

This uses the toolchain pinned in `lean-toolchain`.

## Usage

```lean
import LeanGltf
open LeanGltf

-- Assemble a document by index. Accessors point at buffer views, which point
-- at buffers; the binary payload (`bin`) holds the actual vertex/index data.
def doc : Document := {
  scenes  := #[{ nodes := #[0] }]
  nodes   := #[{ name := some "mesh-node", mesh := some 0 }]
  meshes  := #[{ primitives := #[{
    attributes := #[("POSITION", 0)]
    indices    := some 1
  }] }]
  accessors := #[
    -- POSITION: 3 vec3 floats
    { componentType := 5126, count := 3, type := .vec3,
      bufferView := some 0,
      min := some #[0.0, 0.0, 0.0], max := some #[1.0, 1.0, 0.0] },
    -- indices: 3 unsigned shorts
    { componentType := 5123, count := 3, type := .scalar, bufferView := some 1 }
  ]
  bufferViews := #[
    { buffer := 0, byteOffset := 0,  byteLength := 36,
      target := some BufferView.arrayBuffer },
    { buffer := 0, byteOffset := 36, byteLength := 6,
      target := some BufferView.elementArrayBuffer }
  ]
  buffers := #[{ byteLength := 42 }]
}

def main : IO Unit := do
  let bin : ByteArray := -- packed POSITION + index data (42 bytes)
    ByteArray.empty
  writeGlb "out.glb" doc bin       -- binary GLB
  writeGltfJson "out.gltf" doc     -- text glTF (no embedded binary)
```

The caller is responsible for packing `bin` so that its layout matches the
`byteOffset`/`byteLength` declared in the document's buffer views, and for
ensuring `buffers[0].byteLength = bin.size`.

## API overview

- `LeanGltf.Document` — top-level container; `Document.toJsonString` renders it
  to a glTF JSON string.
- `LeanGltf.GLB.emit doc bin : ByteArray` — serialize a document plus an
  optional binary payload into a complete GLB byte stream.
- `LeanGltf.writeGlb path doc bin : IO Unit` — write a `.glb` file.
- `LeanGltf.writeGltfJson path doc : IO Unit` — write a text `.gltf` file.
- `LeanGltf.JSON` — the minimal JSON value type and encoder used internally.

## License

MIT — see [LICENSE](LICENSE).
