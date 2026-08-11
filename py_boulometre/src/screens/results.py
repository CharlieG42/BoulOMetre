"""
Écran des résultats pour PyBoul'O'Mètre
"""

from kivy.uix.screenmanager import Screen
from kivy.uix.boxlayout import BoxLayout
from kivy.uix.label import Label
from kivy.uix.button import Button
from kivy.uix.scrollview import ScrollView
from kivy.uix.gridlayout import GridLayout
from kivy.properties import ListProperty, ObjectProperty
from kivy.core.window import Window

from ..models.ball import Ball
from ..utils.constants import Constants
from ..utils.helpers import Helpers


class ResultsScreen(Screen):
    """Écran d'affichage des résultats"""
    
    balls = ListProperty([])
    
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.name = "results"
    
    def on_pre_enter(self):
        """Appelé avant d'entrer sur l'écran"""
        # Mettre à jour l'affichage
        self._update_display()
        return super().on_pre_enter()
    
    def _update_display(self):
        """Met à jour l'affichage des résultats"""
        pass  # Géré par le KV
    
    def get_piglet(self) -> Ball:
        """Récupère le cochonnet"""
        piglets = [b for b in self.balls if b.is_piglet]
        return piglets[0] if piglets else None
    
    def get_sorted_balls(self) -> list:
        """Récupère les boules triées par distance"""
        return sorted(
            [b for b in self.balls if not b.is_piglet],
            key=lambda b: b.distance_to_piglet
        )
    
    def get_closest_ball(self) -> Ball:
        """Récupère la boule la plus proche"""
        sorted_balls = self.get_sorted_balls()
        return sorted_balls[0] if sorted_balls else None
    
    def new_measurement(self):
        """Nouvelle mesure"""
        self.manager.current = "camera"
    
    def share_results(self):
        """Partage les résultats (à venir)"""
        from ..app import BoulOMetreApp
        app = BoulOMetreApp.get_running_app()
        if app:
            app.show_snackbar("Fonctionnalité à venir")
    
    def go_back(self):
        """Retour à l'écran d'accueil"""
        self.manager.current = "home"
