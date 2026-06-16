import Lake
open Lake DSL

package «lean-gltf» where
  -- Settings applied to both builds and interactive editing
  leanOptions := #[
    ⟨`pp.unicode.fun, true⟩
  ]

@[default_target]
lean_lib LeanGltf where
  -- The umbrella module `LeanGltf` re-exports the full public surface.
