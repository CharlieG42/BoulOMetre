"""
Widgets personnalisés pour PyBoul'O'Mètre
"""

from kivy.uix.widget import Widget
from kivy.graphics import (
    Color, Line, Circle, Ellipse, Rectangle, Canvas, InstructionGroup
)
from kivy.properties import (
    ListProperty, BooleanProperty, NumericProperty, 
    ReferenceListProperty, ObjectProperty, OptionProperty
)
from kivy.clock import Clock
from kivy.core.window import Window

from ..models.ball import Ball
from ..utils.constants import Constants
from ..utils.helpers import Helpers


class CameraOverlay(Widget):
    """Overlay pour l'écran caméra avec réticule et guides"""
    
    balls = ListProperty([])
    show_measurement_guides = BooleanProperty(False)
    is_selecting_balls = BooleanProperty(False)
    device_pitch = NumericProperty(0.0)
    device_roll = NumericProperty(0.0)
    horizontal_threshold = NumericProperty(0.1)
    
    on_piglet_position_changed = ObjectProperty(None, allownone=True)
    on_ball_added = ObjectProperty(None, allownone=True)
    on_horizontal_changed = ObjectProperty(None, allownone=True)
    
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self._manual_piglet_position = None
        self._drag_start_position = None
        self._is_horizontal = False
        self._last_tilt = 0.0
        
        # Démarrer la détection de l'inclinaison
        Clock.schedule_interval(self._update_orientation, 1/30)
    
    def _update_orientation(self, dt):
        """Met à jour l'orientation de l'appareil"""
        # Simuler la détection de l'inclinaison (à remplacer par des capteurs réels)
        # Pour l'instant, on utilise une valeur par défaut
        pass
    
    def on_touch_down(self, touch):
        """Gère le toucher pour le déplacement du cochonnet ou l'ajout de boules"""
        if self.is_selecting_balls and self.on_ball_added:
            # Mode sélection des boules: ajouter une boule
            self.on_ball_added(touch.pos)
            return True
        
        if not self.is_selecting_balls and self.on_piglet_position_changed:
            # Mode ajustement du cochonnet: commencer le drag
            self._drag_start_position = touch.pos
            return True
        
        return super().on_touch_down(touch)
    
    def on_touch_move(self, touch):
        """Gère le déplacement du cochonnet"""
        if self._drag_start_position is not None and self.on_piglet_position_changed:
            # Calculer le déplacement relatif
            offset_x = touch.pos[0] - self._drag_start_position[0]
            offset_y = touch.pos[1] - self._drag_start_position[1]
            
            # Position actuelle du cochonnet
            center = self.center
            current_pos = self._manual_piglet_position if self._manual_piglet_position else center
            
            # Nouvelle position
            new_pos = (current_pos[0] + offset_x, current_pos[1] + offset_y)
            self._manual_piglet_position = new_pos
            
            # Notifier le changement
            self.on_piglet_position_changed(new_pos)
            
            # Mettre à jour la position de départ
            self._drag_start_position = touch.pos
            return True
        
        return super().on_touch_move(touch)
    
    def on_touch_up(self, touch):
        """Termine le drag"""
        self._drag_start_position = None
        return super().on_touch_up(touch)
    
    def get_piglet_position(self):
        """Récupère la position du cochonnet"""
        return self._manual_piglet_position if self._manual_piglet_position else self.center
    
    def draw_overlay(self):
        """Dessine l'overlay (appelé automatiquement)"""
        pass  # Le dessin est géré par le canvas dans le KV


class DistanceCard(Widget):
    """Carte affichant la distance d'une boule"""
    
    ball = ObjectProperty(None)
    is_closest = BooleanProperty(False)
    
    def __init__(self, **kwargs):
        super().__init__(**kwargs)


class ActionButton(Widget):
    """Bouton d'action personnalisé"""
    
    text = ObjectProperty("Button")
    icon = ObjectProperty(None)
    on_press = ObjectProperty(None)
    background_color = ListProperty(Constants.PRIMARY_COLOR)
    text_color = ListProperty(Constants.TEXT_LIGHT_COLOR)
    
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
