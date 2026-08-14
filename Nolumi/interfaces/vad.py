# This Python file uses the following encoding: utf-8

from __future__ import annotations
from abc import ABC, abstractmethod
from dataclasses import dataclass

@dataclass
class VadResult:
    """
    VAD 单次检测结果。
    """
    speech: bool = False
    speech_start: bool = False
    speech_end: bool = False
    probability: float = 0.0


class IVadPlugin(ABC):
    """
    Nolumi VAD 插件统一接口。
    职责：
    - 接收 PCM 音频数据
    - 判断当前是否存在人声
    - 判断一段讲话何时开始
    - 判断一段讲话何时结束
    不负责：
    - 音频采集
    - ASR
    - LLM
    - TTS
    """
    @abstractmethod
    def initialize(self) -> bool:
        """
        初始化 VAD 模型。
        Returns:
            bool:
                True  初始化成功
                False 初始化失败
        """
        raise NotImplementedError

    @abstractmethod
    def process(self, pcm_bytes: bytes) -> VadResult:
        """
        处理一块 PCM 音频。
        当前 Nolumi 默认音频格式：
            16000 Hz
            Mono
            Int16 PCM
        Args:
            pcm_bytes:
                麦克风采集到的一块 PCM 数据。
        Returns:
            VadResult
        """
        raise NotImplementedError

    @abstractmethod
    def reset(self) -> None:
        """
        重置当前 VAD 状态。

        一般在以下情况调用：
        - 新会话开始
        - 麦克风重新启动
        - 用户主动中断
        - ASR 一句话处理完成
        """
        raise NotImplementedError
    @abstractmethod
    def shutdown(self) -> None:
        """
        释放 VAD 模型及相关资源。
        """
        raise NotImplementedError
