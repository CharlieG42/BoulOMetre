"""
Modèle Ball pour PyBoul'O'Mètre
"""

from dataclasses import dataclass, field
from typing import Optional


@dataclass
class Ball:
    """Représente une boule ou un cochonnet"""
    id: str
    x: float
    y: float
    radius: float
    distance_to_piglet: float = 0.0
    is_piglet: bool = False
    
    def copy_with(
        self,
        id: Optional[str] = None,
        x: Optional[float] = None,
        y: Optional[float] = None,
        radius: Optional[float] = None,
        distance_to_piglet: Optional[float] = None,
        is_piglet: Optional[bool] = None
    ) -> 'Ball':
        """Crée une copie avec des valeurs modifiées"""
        return Ball(
            id=id if id is not None else self.id,
            x=x if x is not None else self.x,
            y=y if y is not None else self.y,
            radius=radius if radius is not None else self.radius,
            distance_to_piglet=distance_to_piglet if distance_to_piglet is not None else self.distance_to_piglet,
            is_piglet=is_piglet if is_piglet is not None else self.is_piglet
        )
    
    def to_dict(self) -> dict:
        """Convertit en dictionnaire"""
        return {
            'id': self.id,
            'x': self.x,
            'y': self.y,
            'radius': self.radius,
            'distance_to_piglet': self.distance_to_piglet,
            'is_piglet': self.is_piglet
        }
    
    @classmethod
    def from_dict(cls, data: dict) -> 'Ball':
        """Crée une Ball à partir d'un dictionnaire"""
        return cls(
            id=data.get('id', ''),
            x=data.get('x', 0.0),
            y=data.get('y', 0.0),
            radius=data.get('radius', 20.0),
            distance_to_piglet=data.get('distance_to_piglet', 0.0),
            is_piglet=data.get('is_piglet', False)
        )
    
    def __repr__(self) -> str:
        return f"Ball(id={self.id}, x={self.x:.1f}, y={self.y:.1f}, radius={self.radius:.1f}, is_piglet={self.is_piglet})"
