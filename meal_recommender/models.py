# meal_recommender/models.py
from django.db import models
import uuid

class UserProfile(models.Model):
    user_id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    allergies = models.TextField(default="", blank=False)
    favorite_foods = models.TextField(default="", blank=False)
    disliked_foods = models.TextField(default="", blank=False)

    def __str__(self):
        return str(self.user_id)

class RecommendationHistory(models.Model):
    user = models.ForeignKey(UserProfile, on_delete=models.CASCADE)
    recommendation = models.TextField()
    timestamp = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.user} - {self.recommendation[:20]}..."