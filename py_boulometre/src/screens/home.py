"""
Écran d'accueil pour PyBoul'O'Mètre
"""

from kivy.uix.screenmanager import Screen
from kivy.uix.boxlayout import BoxLayout
from kivy.uix.button import Button
from kivy.uix.label import Label
from kivy.uix.image import Image
from kivy.uix.scrollview import ScrollView
from kivy.core.window import Window

from ..utils.constants import Constants
from ..app import BoulOMetreApp


class HomeScreen(Screen):
    """Écran d'accueil principal"""
    
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.name = "home"
    
    def go_to_camera(self):
        """Navigue vers l'écran caméra"""
        self.manager.current = "camera"
    
    def go_to_settings(self):
        """Navigue vers les réglages"""
        self.manager.current = "settings"
    
    def show_history(self):
        """Affiche l'historique (à venir)"""
        app = BoulOMetreApp.get_running_app()
        if app:
            app.show_snackbar("Fonctionnalité à venir dans la V2")
