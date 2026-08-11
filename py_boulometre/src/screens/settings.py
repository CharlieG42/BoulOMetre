"""
Écran des réglages pour PyBoul'O'Mètre
"""

from kivy.uix.screenmanager import Screen
from kivy.uix.boxlayout import BoxLayout
from kivy.uix.label import Label
from kivy.uix.slider import Slider
from kivy.uix.button import Button
from kivy.uix.switch import Switch
from kivy.properties import NumericProperty, BooleanProperty
from kivy.core.window import Window

from ..utils.constants import Constants
from ..app import BoulOMetreApp


class SettingsScreen(Screen):
    """Écran des réglages"""
    
    horizontal_threshold = NumericProperty(Constants.DEFAULT_HORIZONTAL_THRESHOLD)
    is_loading = BooleanProperty(True)
    
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.name = "settings"
    
    def on_pre_enter(self):
        """Appelé avant d'entrer sur l'écran"""
        self._load_settings()
        return super().on_pre_enter()
    
    def _load_settings(self):
        """Charge les réglages"""
        # Pour l'instant, on utilise les valeurs par défaut
        # Dans une version future, on pourrait utiliser un fichier de config
        self.horizontal_threshold = Constants.DEFAULT_HORIZONTAL_THRESHOLD
        self.is_loading = False
    
    def _save_settings(self):
        """Sauvegarde les réglages"""
        # Sauvegarder dans un fichier de config
        # Pour l'instant, on affiche juste un message
        app = BoulOMetreApp.get_running_app()
        if app:
            app.show_snackbar("Réglages sauvegardés")
    
    def go_back(self):
        """Retour à l'écran d'accueil"""
        self.manager.current = "home"
