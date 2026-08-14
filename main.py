import sys
from pathlib import Path

from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine

from nolumi.audio.audio_capture import AudioCapture
from nolumi.core.conversation.input_pipeline import InputPipeline

from plugins.vad.silero_vad.plugin import (
    SileroVadPlugin
)


if __name__ == "__main__":

    app = QGuiApplication(sys.argv)

    engine = QQmlApplicationEngine()

    #
    # Audio
    #
    audio_capture = AudioCapture()

    #
    # VAD Plugin
    #
    vad_plugin = SileroVadPlugin()

    #
    # Input Pipeline
    #
    input_pipeline = InputPipeline(
        audio_capture=audio_capture,
        vad_plugin=vad_plugin
    )

    #
    # 先初始化 VAD
    #
    input_pipeline.initialize()

    #
    # 暴露给 QML
    #
    engine.rootContext().setContextProperty(
        "AudioCapture",
        audio_capture
    )

    engine.rootContext().setContextProperty(
        "InputPipeline",
        input_pipeline
    )

    qml_file = (
        Path(__file__).resolve().parent
        / "qml"
        / "main.qml"
    )

    engine.load(qml_file)

    if not engine.rootObjects():
        sys.exit(-1)

    result = app.exec()

    #
    # 程序退出前清理
    #
    input_pipeline.shutdown()

    sys.exit(result)
