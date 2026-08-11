"""
Service de traitement d'image pour PyBoul'O'Mètre
"""

import math
from typing import List
from PIL import Image as PILImage
import numpy as np

from ..models.ball import Ball
from ..utils.constants import Constants


class ImageProcessor:
    """Traitement d'image et détection des boules"""
    
    REAL_BALL_DIAMETER_CM = Constants.REAL_BALL_DIAMETER
    REAL_PIGLET_DIAMETER_CM = Constants.REAL_PIGLET_DIAMETER
    
    @staticmethod
    def detect_balls_and_piglet(image: PILImage.Image) -> List[Ball]:
        """
        Détecte les boules et le cochonnet dans une image.
        Pour cette version simplifiée, on retourne un cochonnet au centre.
        Les boules seront ajoutées manuellement par l'utilisateur.
        """
        width, height = image.size
        
        # Créer un cochonnet au centre de l'image
        piglet = Ball(
            id='piglet',
            x=width / 2,
            y=height / 2,
            radius=Constants.PIGLET_RADIUS,
            is_piglet=True
        )
        
        return [piglet]
    
    @staticmethod
    def calculate_distance(x1: float, y1: float, x2: float, y2: float) -> float:
        """Calcule la distance entre deux points"""
        return math.sqrt((x2 - x1) ** 2 + (y2 - y1) ** 2)
    
    @staticmethod
    def pixels_to_cm(pixels: float, reference_diameter_px: float = 50.0) -> float:
        """Convertit des pixels en centimètres"""
        if reference_diameter_px <= 0:
            reference_diameter_px = 50.0
        scale = Constants.REAL_PIGLET_DIAMETER / reference_diameter_px
        return pixels * scale
    
    @staticmethod
    def cm_to_pixels(cm: float, reference_diameter_px: float = 50.0) -> float:
        """Convertit des centimètres en pixels"""
        if reference_diameter_px <= 0:
            reference_diameter_px = 50.0
        scale = reference_diameter_px / Constants.REAL_PIGLET_DIAMETER
        return cm * scale
    
    @staticmethod
    def process_image_for_detection(image: PILImage.Image) -> np.ndarray:
        """
        Prétraite une image pour la détection (optionnel, pour version future)
        """
        # Convertir en niveaux de gris
        gray = image.convert('L')
        return np.array(gray)
