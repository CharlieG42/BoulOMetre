"""
Fonctions utilitaires pour PyBoul'O'Mètre
"""

import math
from typing import List, Tuple, Optional


class Helpers:
    """Fonctions utilitaires"""
    
    @staticmethod
    def format_distance(cm: float) -> str:
        """Formate une distance en centimètres"""
        return f"{cm:.1f} cm"
    
    @staticmethod
    def format_angle(radians: float) -> str:
        """Formate un angle en degrés"""
        degrees = radians * (180 / math.pi)
        return f"{degrees:.1f}°"
    
    @staticmethod
    def is_point_in_circle(px: float, py: float, cx: float, cy: float, radius: float) -> bool:
        """Vérifie si un point est dans un cercle"""
        distance = math.sqrt((px - cx) ** 2 + (py - cy) ** 2)
        return distance <= radius
    
    @staticmethod
    def calculate_angle(x1: float, y1: float, x2: float, y2: float) -> float:
        """Calcule l'angle entre deux points"""
        return math.atan2(y2 - y1, x2 - x1)
    
    @staticmethod
    def calculate_center(points: List[Tuple[float, float]]) -> Tuple[float, float]:
        """Calcule le centre d'une liste de points"""
        if not points:
            return (0, 0)
        sum_x = sum(p[0] for p in points)
        sum_y = sum(p[1] for p in points)
        return (sum_x / len(points), sum_y / len(points))
    
    @staticmethod
    def generate_id() -> str:
        """Génère un ID unique"""
        import time
        return str(int(time.time() * 1000))
    
    @staticmethod
    def clamp(value: float, min_val: float, max_val: float) -> float:
        """Limite une valeur entre min et max"""
        return max(min_val, min(max_val, value))
