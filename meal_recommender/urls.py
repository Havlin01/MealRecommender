# meal_recommender/urls.py
from django.urls import path
from . import views

urlpatterns = [
    path('preferences/', views.save_preferences, name='save_preferences'),
    path('recommendation/<uuid:user_id>/', views.get_recommendation, name='get_recommendation'),
    path('history/<uuid:user_id>/', views.get_history, name='get_history'),
]