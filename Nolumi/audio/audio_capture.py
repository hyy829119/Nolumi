# This Python file uses the following encoding: utf-8

from __future__ import annotations

import math
from array import array
from typing import Optional

from PySide6.QtCore import (
    QObject,
    Signal,
    Slot,
    Property,
    QByteArray,
)
from PySide6.QtMultimedia import (
    QAudioFormat,
    QAudioSource,
    QMediaDevices,
)


class AudioCapture(QObject):
    """
    Nolumi 麦克风音频采集器。

    当前职责：
    1. 打开默认麦克风
    2. 采集 PCM 音频
    3. 输出 PCM 数据块
    4. 计算实时音量
    5. 向 QML 暴露运行状态和音量

    不负责：
    - VAD
    - ASR
    - LLM
    - Conversation
    """

    # PCM 数据
    audioChunkReady = Signal(bytes)

    # 属性变化通知
    runningChanged = Signal()
    volumeChanged = Signal()

    # 生命周期
    started = Signal()
    stopped = Signal()

    # 错误
    errorOccurred = Signal(str)

    def __init__(
        self,
        parent: Optional[QObject] = None
    ):
        super().__init__(parent)

        self._audio_source: Optional[QAudioSource] = None
        self._audio_io = None

        self._running = False
        self._volume = 0.0

        self._format = QAudioFormat()

        # Nolumi 内部标准音频格式
        self._format.setSampleRate(16000)
        self._format.setChannelCount(1)
        self._format.setSampleFormat(
            QAudioFormat.Int16
        )

    # =========================================================
    # QML Properties
    # =========================================================

    @Property(bool, notify=runningChanged)
    def running(self) -> bool:
        """
        当前麦克风是否正在采集。
        """
        return self._running

    @Property(float, notify=volumeChanged)
    def volume(self) -> float:
        """
        当前麦克风音量。

        范围：
        0.0 ~ 1.0
        """
        return self._volume

    # =========================================================
    # Public API
    # =========================================================

    @Slot()
    def start(self) -> None:
        """
        开始采集麦克风。
        """

        if self._running:
            return

        try:
            device = QMediaDevices.defaultAudioInput()

            if device.isNull():
                self.errorOccurred.emit(
                    "No audio input device found."
                )
                return

            if not device.isFormatSupported(
                self._format
            ):
                self.errorOccurred.emit(
                    "The current microphone does not support "
                    "16000 Hz / Mono / Int16 PCM."
                )
                return

            self._audio_source = QAudioSource(
                device,
                self._format,
                self
            )

            self._audio_io = (
                self._audio_source.start()
            )

            if self._audio_io is None:
                self.errorOccurred.emit(
                    "Failed to start microphone."
                )

                self._cleanup()
                return

            #
            # QIODevice 有数据时通知我们读取。
            #
            self._audio_io.readyRead.connect(
                self._on_audio_ready
            )

            self._set_running(True)

            print(
                "[AudioCapture] started"
            )

            print(
                "[AudioCapture] device:",
                device.description()
            )

            print(
                "[AudioCapture] format:"
                " 16000 Hz / Mono / Int16"
            )

            self.started.emit()

        except Exception as exc:

            self._cleanup()

            self.errorOccurred.emit(
                str(exc)
            )

    @Slot()
    def stop(self) -> None:
        """
        停止麦克风采集。
        """

        if not self._running:
            return

        if self._audio_source is not None:
            self._audio_source.stop()

        self._set_running(False)
        self._set_volume(0.0)

        print(
            "[AudioCapture] stopped"
        )

        self.stopped.emit()

        self._cleanup()

    # =========================================================
    # Audio
    # =========================================================

    @Slot()
    def _on_audio_ready(self) -> None:
        """
        麦克风有 PCM 数据时调用。
        """

        if not self._running:
            return

        if self._audio_io is None:
            return

        data: QByteArray = (
            self._audio_io.readAll()
        )

        if data.isEmpty():
            return

        pcm_bytes = bytes(data)

        #
        # 计算音量
        #
        volume = self._calculate_volume(
            pcm_bytes
        )

        self._set_volume(volume)

        #
        # 后面 VAD / ASR 会监听这个 Signal。
        #
        self.audioChunkReady.emit(
            pcm_bytes
        )

    # =========================================================
    # Volume
    # =========================================================

    def _calculate_volume(
        self,
        pcm_bytes: bytes
    ) -> float:
        """
        根据 Int16 PCM 计算 RMS 音量。

        返回：
        0.0 ~ 1.0
        """

        if len(pcm_bytes) < 2:
            return 0.0

        #
        # Int16 = 每个采样 2 字节
        #
        samples = array(
            "h",
            pcm_bytes
        )

        if len(samples) == 0:
            return 0.0

        square_sum = 0.0

        for sample in samples:
            square_sum += (
                float(sample)
                * float(sample)
            )

        rms = math.sqrt(
            square_sum / len(samples)
        )

        #
        # Int16 最大值约为 32768
        #
        volume = rms / 32768.0

        #
        # 限制范围
        #
        return max(
            0.0,
            min(volume, 1.0)
        )

    # =========================================================
    # State
    # =========================================================

    def _set_running(
        self,
        value: bool
    ) -> None:

        if self._running == value:
            return

        self._running = value

        self.runningChanged.emit()

    def _set_volume(
        self,
        value: float
    ) -> None:

        #
        # 避免音量变化极小时疯狂刷新 QML。
        #
        if abs(
            self._volume - value
        ) < 0.001:
            return

        self._volume = value

        self.volumeChanged.emit()

    # =========================================================
    # Cleanup
    # =========================================================

    def _cleanup(self) -> None:

        self._audio_io = None
        self._audio_source = None
