"""
Écran caméra pour PyBoul'O'Mètre
"""

from kivy.uix.screenmanager import Screen
from kivy.uix.boxlayout import BoxLayout
from kivy.uix.button import Button
from kivy.uix.label import Label
from kivy.uix.image import Image
from kivy.uix.floatlayout import FloatLayout
from kivy.uix.popup import Popup
from kivy.graphics.texture import Texture
from kivy.clock import Clock
from kivy.properties import (
    ObjectProperty, ListProperty, BooleanProperty, 
    NumericProperty, StringProperty
)
from kivy.core.window import Window
from PIL import Image as PILImage
import cv2
import numpy as np

from ..models.ball import Ball
from ..services.camera_service import CameraService
from ..services.image_processor import ImageProcessor
from ..utils.constants import Constants
from ..utils.helpers import Helpers
from ..widgets.custom_widgets import CameraOverlay


class CameraScreen(Screen):
    """Écran de la caméra avec détection"""
    
    camera_service = ObjectProperty(None)
    balls = ListProperty([])
    is_processing = BooleanProperty(False)
    is_camera_ready = BooleanProperty(False)
    error_message = StringProperty("")
    show_measurement_guides = BooleanProperty(False)
    is_selecting_balls = BooleanProperty(False)
    is_horizontal = BooleanProperty(False)
    horizontal_threshold = NumericProperty(Constants.DEFAULT_HORIZONTAL_THRESHOLD)
    
    captured_image = ObjectProperty(None)
    manual_piglet_position = ObjectProperty(None)
    
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.name = "camera"
        self.camera_service = CameraService()
        self._frame_clock = None
    
    def on_pre_enter(self):
        """Appelé avant d'entrer sur l'écran"""
        self._initialize_camera()
        return super().on_pre_enter()
    
    def on_leave(self):
        """Appelé en quittant l'écran"""
        self._stop_camera()
        return super().on_leave()
    
    def _initialize_camera(self):
        """Initialise la caméra"""
        try:
            if self.camera_service.initialize():
                self.is_camera_ready = True
                self.error_message = ""
                self._start_camera_preview()
            else:
                self.is_camera_ready = False
                self.error_message = "Impossible d'initialiser la caméra"
        except Exception as e:
            self.is_camera_ready = False
            self.error_message = f"Erreur caméra: {str(e)}"
    
    def _start_camera_preview(self):
        """Démarre l'aperçu de la caméra"""
        if self._frame_clock:
            self._frame_clock.cancel()
        
        def update_frame(dt):
            frame = self.camera_service.get_frame()
            if frame is not None:
                # Mettre à jour l'image de l'aperçu
                self._update_preview(frame)
        
        self._frame_clock = Clock.schedule_interval(update_frame, 1/30)
    
    def _stop_camera(self):
        """Arrête la caméra"""
        if self._frame_clock:
            self._frame_clock.cancel()
            self._frame_clock = None
        self.camera_service.dispose()
    
    def _update_preview(self, frame):
        """Met à jour l'aperçu de la caméra"""
        # Trouver l'Image widget pour l'aperçu
        preview = self.ids.get('camera_preview')
        if preview:
            # Convertir en texture
            frame_flipped = cv2.flip(frame, 0)
            texture = Texture.create(size=(frame.shape[1], frame.shape[0]))
            texture.blit_buffer(frame_flipped.tobytes(), colorfmt='rgb', bufferfmt='ubyte')
            preview.texture = texture
    
    def capture_and_process(self):
        """Capture une image et traite pour la détection"""
        if self.is_processing or not self.is_camera_ready:
            return
        
        self.is_processing = True
        
        try:
            # Prendre une photo
            pil_image = self.camera_service.take_picture()
            if pil_image is None:
                self.is_processing = False
                return
            
            # Stocker l'image capturée
            self.captured_image = pil_image
            
            # Détecter les boules et le cochonnet
            balls = ImageProcessor.detect_balls_and_piglet(pil_image)
            
            # Si l'utilisateur a ajusté manuellement la position du cochonnet
            if self.manual_piglet_position:
                updated_balls = []
                for ball in balls:
                    if ball.is_piglet:
                        updated_balls.append(ball.copy_with(
                            x=self.manual_piglet_position[0],
                            y=self.manual_piglet_position[1]
                        ))
                    else:
                        updated_balls.append(ball)
                balls = updated_balls
            
            self.balls = balls
            self.show_measurement_guides = True
            self.manual_piglet_position = None
            
        except Exception as e:
            app = BoulOMetreApp.get_running_app()
            if app:
                app.show_snackbar(f"Erreur: {str(e)}")
        finally:
            self.is_processing = False
    
    def confirm_measurement(self):
        """Confirme la mesure et passe en mode sélection des boules"""
        if not self.balls:
            return
        
        self.show_measurement_guides = False
        self.is_selecting_balls = True
    
    def add_ball_at_position(self, position):
        """Ajoute une boule à la position spécifiée"""
        if not self.is_selecting_balls:
            return
        
        # Créer une nouvelle boule
        new_ball = Ball(
            id=f'ball_{len([b for b in self.balls if not b.is_piglet]) + 1}',
            x=position[0],
            y=position[1],
            radius=Constants.BALL_RADIUS,
            is_piglet=False
        )
        
        self.balls.append(new_ball)
    
    def finish_ball_selection(self):
        """Termine la sélection des boules et calcule les distances"""
        if len([b for b in self.balls if not b.is_piglet]) < 1:
            return
        
        # Trouver le cochonnet
        piglet = next((b for b in self.balls if b.is_piglet), None)
        if not piglet:
            return
        
        # Calculer les distances
        updated_balls = []
        for ball in self.balls:
            if not ball.is_piglet:
                distance = ImageProcessor.calculate_distance(
                    ball.x, ball.y, piglet.x, piglet.y
                )
                updated_balls.append(ball.copy_with(distance_to_piglet=distance))
            else:
                updated_balls.append(ball)
        
        # Trier les boules par distance
        sorted_balls = sorted(
            [b for b in updated_balls if not b.is_piglet],
            key=lambda b: b.distance_to_piglet
        )
        
        # Attribuer les rangs
        ranked_balls = []
        for ball in updated_balls:
            if ball.is_piglet:
                ranked_balls.append(ball)
            else:
                rank = sorted_balls.index(ball) + 1
                ranked_balls.append(ball.copy_with(id=f'Boule {rank}'))
        
        self.balls = ranked_balls
        self.is_selecting_balls = False
        
        # Naviguer vers les résultats
        self.manager.current = "results"
        
        # Passer les données à l'écran résultats
        results_screen = self.manager.get_screen("results")
        if results_screen:
            results_screen.balls = ranked_balls
    
    def cancel_measurement(self):
        """Annule la mesure en cours"""
        self.show_measurement_guides = False
        self.is_selecting_balls = False
        self.balls = []
        self.manual_piglet_position = None
        self.captured_image = None
    
    def handle_piglet_position_changed(self, position):
        """Gère le changement de position du cochonnet"""
        self.manual_piglet_position = position
    
    def toggle_flash(self):
        """Active/désactive le flash"""
        try:
            self.camera_service.toggle_flash()
        except Exception as e:
            app = BoulOMetreApp.get_running_app()
            if app:
                app.show_snackbar(f"Erreur flash: {str(e)}")
    
    def switch_camera(self):
        """Change de caméra"""
        try:
            if self.camera_service.switch_camera():
                self.balls = []
                self.show_measurement_guides = False
                self.manual_piglet_position = None
        except Exception as e:
            app = BoulOMetreApp.get_running_app()
            if app:
                app.show_snackbar(f"Erreur caméra: {str(e)}")
    
    def go_back(self):
        """Retour à l'écran d'accueil"""
        self.manager.current = "home"
