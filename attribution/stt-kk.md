# stt-kk — Kazakh speech recognition

| | |
|---|---|
| Files | `encoder.onnx`, `decoder_joint.onnx`, `tokens.txt`, `model.json`, `silero_vad.onnx` |
| Acoustic model | NVIDIA `stt_kk_ru_fastconformer_hybrid_large` (FastConformer, transducer head), Kazakh + Russian |
| Source | https://huggingface.co/nvidia/stt_kk_ru_fastconformer_hybrid_large |
| License | Creative Commons Attribution 4.0 International (CC BY 4.0), see `LICENSE` |
| Changes | Exported from NeMo to ONNX (encoder + decoder/joint), encoder quantized to int8 |
| Voice activity detector | Silero VAD v5 — https://github.com/snakers4/silero-vad — MIT License, see `LICENSE-silero-vad` |

Required attribution:

> Speech recognition: NVIDIA `stt_kk_ru_fastconformer_hybrid_large` (CC BY 4.0), converted to ONNX and quantized. Voice activity detection: Silero VAD (MIT).
