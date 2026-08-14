import sys

from PySide6.QtCore import QTimer
from PySide6.QtGui import QGuiApplication

from nolumi.audio.audio_capture import AudioCapture


def on_audio_chunk(data: bytes):
    print("PCM chunk:", len(data), "bytes")


if __name__ == "__main__":
    app = QGuiApplication(sys.argv)

    capture = AudioCapture()

    capture.audio_chunk_ready.connect(on_audio_chunk)

    capture.error_occurred.connect(
        lambda message: print("Audio error:", message)
    )

    capture.start()

    # 10 秒后自动停止
    QTimer.singleShot(
        10000,
        capture.stop
    )

    QTimer.singleShot(
        10500,
        app.quit
    )

    sys.exit(app.exec())
