"""
Application principale PyBoul'O'Mètre
"""

from kivy.app import App
from kivy.uix.screenmanager import ScreenManager, NoTransition
from kivy.lang import Builder
from kivy.properties import ObjectProperty
from kivy.core.window import Window
from kivy.utils import platform

from .screens.home import HomeScreen
from .screens.camera import CameraScreen
from .screens.results import ResultsScreen
from .screens.settings import SettingsScreen
from .utils.constants import Constants


# Charger les fichiers KV
Builder.load_file('src/screens/home.kv')
Builder.load_file('src/screens/camera.kv')
Builder.load_file('src/screens/results.kv')
Builder.load_file('src/screens/settings.kv')
Builder.load_file('src/widgets/custom_widgets.kv')


class BoulOMetreApp(App):
    """Application principale"""
    
    screen_manager = ObjectProperty(None)
    snackbar = ObjectProperty(None)
    
    def build(self):
        """Construire l'application"""
        # Configurer la fenêtre
        Window.clearcolor = Constants.BACKGROUND_COLOR
        
        if platform in ('android', 'ios'):
            Window.fullscreen = True
        else:
            Window.size = (400, 800)
        
        # Créer le gestionnaire d'écrans
        self.screen_manager = ScreenManager(transition=NoTransition())
        
        # Ajouter les écrans
        self.screen_manager.add_widget(HomeScreen(name='home'))
        self.screen_manager.add_widget(CameraScreen(name='camera'))
        self.screen_manager.add_widget(ResultsScreen(name='results'))
        self.screen_manager.add_widget(SettingsScreen(name='settings'))
        
        return self.screen_manager
    
    def show_snackbar(self, message: str, duration: float = 3.0):
        """Affiche un message snackbar"""
        # Implémentation simplifiée du snackbar
        print(f"Snackbar: {message}")
        # Dans une version complète, on utiliserait un widget Snackbar
    
    def on_start(self):
        """Appelé au démarrage de l'application"""
        pass
    
    def on_stop(self):
        """Appelé à l'arrêt de l'application"""
        # Nettoyer les ressources
        pass


if __name__ == '__main__':
    BoulOMetreApp().run()
