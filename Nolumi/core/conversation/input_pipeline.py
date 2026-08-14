# This Python file uses the following encoding: utf-8

from __future__ import annotations

from typing import Optional

from PySide6.QtCore import QObject, Signal, Slot, Property

from nolumi.audio.audio_capture import AudioCapture
from nolumi.audio.audio_buffer import AudioBuffer
from nolumi.interfaces.vad import IVadPlugin


class InputPipeline(QObject):
    """
    Nolumi 输入语音管线。

    当前链路：

        Microphone
            ↓
        AudioCapture
            ↓
        AudioBuffer
            ↓
        VAD
            ↓
        speechStarted / speechEnded

    后续继续扩展：

        VAD
            ↓
        ASR
            ↓
        LLM
    """

    speechActiveChanged = Signal()
    vadReadyChanged = Signal()

    speechStarted = Signal()
    speechEnded = Signal()

    errorOccurred = Signal(str)

    def __init__(
        self,
        audio_capture: AudioCapture,
        vad_plugin: IVadPlugin,
        parent: Optional[QObject] = None,
    ):
        super().__init__(parent)

        self._audio_capture = audio_capture
        self._vad = vad_plugin

        self._speech_active = False
        self._vad_ready = False

        #
        # Silero VAD
        #
        # 16000 Hz
        # 512 samples
        # Int16 = 2 bytes/sample
        #
        self._audio_buffer = AudioBuffer(
            frame_samples=512,
            bytes_per_sample=2,
        )

        self._audio_capture.audioChunkReady.connect(
            self._on_audio_chunk
        )

        self._audio_capture.started.connect(
            self._on_capture_started
        )

        self._audio_capture.stopped.connect(
            self._on_capture_stopped
        )

        self._audio_capture.errorOccurred.connect(
            self.errorOccurred
        )

    # =========================================================
    # Properties
    # =========================================================

    @Property(bool, notify=speechActiveChanged)
    def speechActive(self) -> bool:
        return self._speech_active

    @Property(bool, notify=vadReadyChanged)
    def vadReady(self) -> bool:
        return self._vad_ready

    @Property(bool, notify=speechActiveChanged)
    def running(self) -> bool:
        return self._audio_capture.running

    # =========================================================
    # Initialization
    # =========================================================

    def initialize(self) -> bool:
        """
        初始化输入管线。
        """

        if self._vad_ready:
            return True

        print("[InputPipeline] initializing VAD...")

        result = self._vad.initialize()

        self._vad_ready = result
        self.vadReadyChanged.emit()

        if result:
            print("[InputPipeline] VAD ready")
        else:
            print("[InputPipeline] VAD initialization failed")

        return result

    # =========================================================
    # Public API
    # =========================================================

    @Slot()
    def start(self) -> None:
        """
        开始监听麦克风。
        """

        if not self._vad_ready:
            if not self.initialize():
                self.errorOccurred.emit(
                    "VAD initialization failed."
                )
                return

        self._audio_buffer.reset()
        self._vad.reset()

        self._set_speech_active(False)

        self._audio_capture.start()

    @Slot()
    def stop(self) -> None:
        """
        停止监听。
        """

        self._audio_capture.stop()

        self._audio_buffer.reset()
        self._vad.reset()

        self._set_speech_active(False)

    # =========================================================
    # Audio Processing
    # =========================================================

    @Slot(bytes)
    def _on_audio_chunk(
        self,
        data: bytes
    ) -> None:

        #
        # QAudioSource 返回的数据长度不固定。
        #
        # AudioBuffer 将其切成：
        #
        # 512 samples
        # 1024 bytes
        #
        frames = self._audio_buffer.append(data)

        for frame in frames:

            result = self._vad.process(frame)

            if result.speech_start:

                print(
                    "[InputPipeline] >>> SPEECH START"
                )

                self._set_speech_active(True)

                self.speechStarted.emit()

            elif result.speech_end:

                print(
                    "[InputPipeline] <<< SPEECH END"
                )

                self._set_speech_active(False)

                self.speechEnded.emit()

    # =========================================================
    # AudioCapture callbacks
    # =========================================================

    def _on_capture_started(self) -> None:
        print(
            "[InputPipeline] microphone started"
        )

    def _on_capture_stopped(self) -> None:

        print(
            "[InputPipeline] microphone stopped"
        )

        self._set_speech_active(False)

    # =========================================================
    # State
    # =========================================================

    def _set_speech_active(
        self,
        value: bool
    ) -> None:

        if self._speech_active == value:
            return

        self._speech_active = value

        self.speechActiveChanged.emit()

    # =========================================================
    # Cleanup
    # =========================================================

    def shutdown(self) -> None:
        self.stop()
        self._vad.shutdown()
