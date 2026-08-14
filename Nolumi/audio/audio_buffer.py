# This Python file uses the following encoding: utf-8

from __future__ import annotations

from collections import deque
from typing import Optional


class AudioBuffer:
    """
    Nolumi PCM 音频分块缓冲器。

    作用：
    将 QAudioSource 产生的不定长 PCM 数据，
    整理成固定大小的音频块。

    当前默认：
        Sample Rate: 16000 Hz
        Channels:    1
        Format:      Int16

    Silero VAD:
        512 samples
        1024 bytes
        32 ms
    """

    def __init__(
        self,
        frame_samples: int = 512,
        bytes_per_sample: int = 2,
    ):
        self._frame_samples = frame_samples
        self._bytes_per_sample = bytes_per_sample

        self._frame_bytes = (
            frame_samples * bytes_per_sample
        )

        self._buffer = bytearray()

    @property
    def frame_samples(self) -> int:
        return self._frame_samples

    @property
    def frame_bytes(self) -> int:
        return self._frame_bytes

    @property
    def buffered_bytes(self) -> int:
        return len(self._buffer)

    def append(
        self,
        data: bytes
    ) -> list[bytes]:
        """
        添加任意长度 PCM 数据。

        返回所有已经凑齐的固定长度 frame。
        """

        if not data:
            return []

        self._buffer.extend(data)

        frames: list[bytes] = []

        while len(self._buffer) >= self._frame_bytes:

            frame = bytes(
                self._buffer[:self._frame_bytes]
            )

            del self._buffer[:self._frame_bytes]

            frames.append(frame)

        return frames

    def reset(self) -> None:
        """
        清空缓存。
        """
        self._buffer.clear()
