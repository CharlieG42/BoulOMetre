"""
Constantes globales pour l'application PyBoul'O'Mètre
"""

from kivy.utils import get_color_from_hex


class Constants:
    """Constantes de l'application"""
    
    # Couleurs
    PRIMARY_COLOR = get_color_from_hex("#8B4513")  # Marron
    SECONDARY_COLOR = get_color_from_hex("#CD853F")  # Marron clair
    ACCENT_COLOR = get_color_from_hex("#FFD700")  # Or
    BACKGROUND_COLOR = get_color_from_hex("#F5F5F5")  # Gris très clair
    SURFACE_COLOR = get_color_from_hex("#FFFFFF")  # Blanc
    BALL_COLOR = get_color_from_hex("#4682B4")  # Bleu
    PIGLET_COLOR = get_color_from_hex("#DC143C")  # Rouge
    CLOSEST_BALL_COLOR = get_color_from_hex("#228B22")  # Vert
    TEXT_COLOR = get_color_from_hex("#000000")  # Noir
    TEXT_LIGHT_COLOR = get_color_from_hex("#FFFFFF")  # Blanc
    
    # Espacements
    DEFAULT_PADDING = 16
    SMALL_PADDING = 8
    LARGE_PADDING = 24
    BORDER_RADIUS = 12
    
    # Tailles
    CROSSHAIR_SIZE = 40
    BALL_RADIUS = 20
    PIGLET_RADIUS = 15
    
    # Diamètres réels (en cm)
    REAL_BALL_DIAMETER = 7.5
    REAL_PIGLET_DIAMETER = 3.0
    DEFAULT_BALL_DIAMETER_PX = 50.0
    
    # Noms
    APP_NAME = "PyBoul'O'Mètre"
    APP_TAGLINE = "Mesurez vos lancers de pétanque avec précision"
    
    # Seuil d'horizontalité par défaut
    DEFAULT_HORIZONTAL_THRESHOLD = 0.1
    
    # Animation
    ANIMATION_DURATION = 0.3
