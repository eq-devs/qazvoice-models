# qazvoice-models

Model files for the [`qazvoice`](https://github.com/eq-devs/qazvoice) Flutter plugin
(on-device Kazakh text-to-speech and speech recognition). The plugin downloads them on
demand; nothing here needs to be fetched by hand.

Each model is one GitHub Release. Every release contains the model files, its
`LICENSE` and an `ATTRIBUTION.md`. The `catalog` release holds `catalog.json`, the
list the plugin reads (sizes and SHA-256 of every file).

| id | release | size | contents | license |
|---|---|---|---|---|
| `tts-kk` | [`tts-kk-v1`](https://github.com/eq-devs/qazvoice-models/releases/tag/tts-kk-v1) | 128 MB | Piper `kk_KZ-issai-high` voice, 6 speakers, 22 050 Hz | CC BY 4.0 (ISSAI) |
| `stt-kk` | [`stt-kk-v1`](https://github.com/eq-devs/qazvoice-models/releases/tag/stt-kk-v1) | 196 MB | NVIDIA FastConformer kk-ru transducer (int8 ONNX) + Silero VAD | CC BY 4.0 + MIT |
| `punct-kk` | [`punct-kk-v1`](https://github.com/eq-devs/qazvoice-models/releases/tag/punct-kk-v1) | 114 MB | XLM-R punctuation + true-casing, pruned (optional) | Apache-2.0 |

Attribution texts for your app's licenses screen are in [`attribution/`](attribution)
and are also returned by `QazVoice.attributions` in the plugin.

## catalog.json

```json
{
  "schema": 1,
  "models": {
    "tts-kk": {
      "version": 1, "kind": "tts", "release": "tts-kk-v1",
      "license": "CC-BY-4.0", "attribution": "…", "minPlugin": "0.0.1",
      "files": [{"name": "voice.onnx", "size": 127864258, "sha256": "…"}],
      "mirrors": ["https://github.com/eq-devs/qazvoice-models/releases/download/{release}/{file}"]
    }
  }
}
```

Mirror URLs are templates with `{id}`, `{version}`, `{release}` and `{file}`. Apps can
add their own mirrors (for example a company server) with `QazVoice.init(mirrors: …)`.

## Publishing a new model version

1. Put the files in a directory, bump `version` and `release` for that model in
   `catalog.json`, fill in `size` / `sha256` (`tool/release.sh` prints them).
2. `tool/release.sh <id> <dir>` creates the release with the files, `LICENSE` and
   `ATTRIBUTION.md`.
3. `tool/release.sh catalog` re-uploads `catalog.json`.

Old releases are never deleted, so apps with an older plugin keep working.

The files in this repository (catalog, scripts, docs) are Apache-2.0. The model files
carry their own licenses, listed above.
