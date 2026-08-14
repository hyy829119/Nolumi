# This Python file uses the following encoding: utf-8
from __future__ import annotations
from array import array
from typing import Optional
import numpy as np
import torch
from silero_vad import load_silero_vad, VADIterator
from nolumi.interfaces.vad import IVadPlugin, VadResult


class SileroVadPlugin(IVadPlugin):
    """
    Nolumi Silero VAD 插件。
    输入格式：
        16000 Hz
        Mono
        Int16 PCM
    职责：
        - 判断当前音频是否为语音
        - 检测 speech_start
        - 检测 speech_end
    """
    SAMPLE_RATE = 16000
    def __init__(self):
        self._model = None
        self._iterator: Optional[VADIterator] = None
        self._initialized = False
        self._is_speaking = False
    def initialize(self) -> bool:
        """
        加载 Silero VAD 模型。
        """
        if self._initialized:
            return True
        try:
            print("[SileroVAD] loading model...")
            self._model = load_silero_vad()
            self._iterator = VADIterator(
                self._model,
                sampling_rate=self.SAMPLE_RATE
            )
            self._initialized = True
            print("[SileroVAD] initialized")
            return True
        except Exception as exc:
            print(
                "[SileroVAD] initialization failed:",
                exc
            )
            self._model = None
            self._iterator = None
            self._initialized = False
            return False

    def process(self, pcm_bytes: bytes) -> VadResult:
        """
        处理一块 Int16 PCM 音频。
        """
        if not self._initialized:
            return VadResult()
        if self._iterator is None:
            return VadResult()
        if not pcm_bytes:
            return VadResult()

        try:
            audio_tensor = self._pcm_to_tensor(
                pcm_bytes
            )
            if audio_tensor.numel() == 0:
                return VadResult()
            #
            # VADIterator 返回类似：
            #
            # {"start": 1234}
            #
            # 或：
            #
            # {"end": 5678}
            #
            # 没有事件时返回 None。
            #
            event = self._iterator(
                audio_tensor,
                return_seconds=False
            )
            speech_start = False
            speech_end = False

            if event is not None:
                if "start" in event:
                    speech_start = True
                    self._is_speaking = True

                if "end" in event:
                    speech_end = True
                    self._is_speaking = False

            # probability = self._calculate_probability(
            #     audio_tensor
            # )

            return VadResult(
                speech=self._is_speaking,
                speech_start=speech_start,
                speech_end=speech_end,
                probability=1.0 if self._is_speaking else 0.0
            )

        except Exception as exc:
            print(
                "[SileroVAD] process error:",
                exc
            )

            return VadResult()

    def reset(self) -> None:
        """
        重置当前流式 VAD 状态。
        """
        self._is_speaking = False
        if self._iterator is not None:
            self._iterator.reset_states()

    def shutdown(self) -> None:
        """
        释放模型。
        """
        self.reset()
        self._iterator = None
        self._model = None
        self._initialized = False
        print("[SileroVAD] shutdown")

    def _pcm_to_tensor(
        self,
        pcm_bytes: bytes
    ) -> torch.Tensor:
        """
        Int16 PCM -> float32 Tensor
        Silero 需要归一化后的浮点音频：
        -1.0 ~ 1.0
        """
        samples = array(
            "h",
            pcm_bytes
        )
        if len(samples) == 0:
            return torch.empty(
                0,
                dtype=torch.float32
            )
        audio = np.asarray(
            samples,
            dtype=np.float32
        )
        audio /= 32768.0
        return torch.from_numpy(audio)

    def _calculate_probability(
        self,
        audio_tensor: torch.Tensor
    ) -> float:
        """
        获取当前 chunk 的 speech probability。
        这里只作为调试/界面数据显示。
        """
        if self._model is None:
            return 0.0
        try:
            with torch.no_grad():
                probability = self._model(
                    audio_tensor,
                    self.SAMPLE_RATE
                )
            return float(
                probability.item()
            )
        except Exception:
            return 0.0
