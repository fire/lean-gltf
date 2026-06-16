import LeanGltf.JSON
import LeanGltf.Types
import LeanGltf.Document
import LeanGltf.GLB
import LeanGltf.Writer

/-!
# `LeanGltf` — umbrella import

A writer-only library for the glTF 2.0 / GLB graph. Import this module to
pull in the full surface.

```
import LeanGltf
open LeanGltf
let doc : Document := { … }
writeGlb "out.glb" doc bin
```
-/
