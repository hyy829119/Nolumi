import sys

from PySide6.QtGui import QGuiApplication
from PySide6.QtCore import QTimer

from nolumi.audio.audio_capture import AudioCapture


if __name__ == "__main__":
    app = QGuiApplication(sys.argv)

    capture = AudioCapture()

    chunk_count = 0

    def on_audio(data: bytes):
        global chunk_count

        chunk_count += 1

        print(
            f"chunk={chunk_count}, "
            f"bytes={len(data)}, "
            f"volume={capture.volume:.4f}"
        )

    capture.audioChunkReady.connect(on_audio)

    capture.errorOccurred.connect(
        lambda message: print(
            "Audio error:",
            message
        )
    )

    capture.start()

    QTimer.singleShot(
        15000,
        capture.stop
    )

    QTimer.singleShot(
        15500,
        app.quit
    )

    sys.exit(app.exec())
