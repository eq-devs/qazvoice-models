# stt-kk-giga — Kazakh speech recognition, high accuracy (optional)

| | |
|---|---|
| Files | `model.onnx`, `model.json`, `tokens.txt`, `silero_vad.onnx` |
| Acoustic model | GigaAM Multilingual (CTC, 221M parameters; Kazakh, Russian, Kyrgyz, Uzbek) by Sber AI (ai-sage) |
| Source | https://huggingface.co/ai-sage/GigaAM-Multilingual, https://github.com/salute-developers/GigaAM |
| License | MIT, see `LICENSE` |
| Changes | Exported to ONNX and quantized to int8 (`model.onnx`) |
| Voice activity detector | Silero VAD v5 — https://github.com/snakers4/silero-vad — MIT License, see `LICENSE-silero-vad` |

Measured with the qazvoice engine on 50 FLEURS Kazakh recordings (13.6 min): word error
rate 7.8% (default `stt-kk`: 10.3%), about 1.6× slower than `stt-kk`.

Attribution:

> Speech recognition: GigaAM Multilingual by Sber AI (MIT), quantized to int8. Voice activity detection: Silero VAD (MIT).
