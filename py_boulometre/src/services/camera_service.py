"""
Service caméra pour PyBoul'O'Mètre
"""

from typing import Optional, Callable, Any
from kivy.graphics.texture import Texture
from kivy.uix.image import Image as KivyImage
import cv2
import numpy as np
from PIL import Image as PILImage


class CameraService:
    """Service de gestion de la caméra"""
    
    def __init__(self):
        self.capture = None
        self.texture = None
        self.is_running = False
        self.current_frame = None
        self.flash_mode = False
        self.camera_index = 0
    
    def initialize(self, camera_index: int = 0) -> bool:
        """Initialise la caméra"""
        try:
            self.capture = cv2.VideoCapture(camera_index)
            if not self.capture.isOpened():
                # Essayer avec un autre index
                self.capture = cv2.VideoCapture(1)
                if not self.capture.isOpened():
                    return False
            self.camera_index = camera_index
            self.is_running = True
            return True
        except Exception as e:
            print(f"Erreur d'initialisation de la caméra: {e}")
            return False
    
    def start(self, update_callback: Optional[Callable] = None) -> bool:
        """Démarre la capture vidéo"""
        if not self.is_running:
            return False
        self.update_callback = update_callback
        return True
    
    def get_frame(self) -> Optional[np.ndarray]:
        """Récupère une frame de la caméra"""
        if not self.is_running or self.capture is None:
            return None
        
        ret, frame = self.capture.read()
        if ret:
            # Convertir de BGR à RGB
            frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            self.current_frame = frame
            return frame
        return None
    
    def take_picture(self) -> Optional[PILImage.Image]:
        """Prend une photo"""
        frame = self.get_frame()
        if frame is not None:
            return PILImage.fromarray(frame)
        return None
    
    def toggle_flash(self) -> bool:
        """Active/désactive le flash"""
        # Note: Le flash n'est pas supporté avec OpenCV sur tous les appareils
        # Cela dépend du matériel et des pilotes
        self.flash_mode = not self.flash_mode
        return self.flash_mode
    
    def switch_camera(self) -> bool:
        """Change de caméra (avant/arrière)"""
        if self.capture:
            self.capture.release()
        
        # Essayer l'autre caméra
        new_index = 1 if self.camera_index == 0 else 0
        if self.initialize(new_index):
            return True
        
        # Si ça échoue, revenir à l'originale
        return self.initialize(self.camera_index)
    
    def dispose(self):
        """Libère les ressources de la caméra"""
        if self.capture:
            self.capture.release()
            self.capture = None
        self.is_running = False
        self.current_frame = None
    
    def get_texture(self) -> Optional[Texture]:
        """Récupère une texture Kivy à partir de la frame actuelle"""
        frame = self.get_frame()
        if frame is not None:
            # Convertir en texture Kivy
            frame_flipped = cv2.flip(frame, 0)  # Flip vertical pour Kivy
            texture = Texture.create(size=(frame.shape[1], frame.shape[0]))
            texture.blit_buffer(frame_flipped.tobytes(), colorfmt='rgb', bufferfmt='ubyte')
            return texture
        return None
