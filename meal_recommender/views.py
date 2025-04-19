# meal_recommender/views.py
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
import json
from .models import UserProfile, RecommendationHistory

# Placeholder function for AI recommendation (to be implemented later)
def get_ai_recommendation(prompt):
    # In a real application, this would call your AI model
    return f"AI suggests: Delicious Pasta with your favorite {prompt}!"

def save_preferences(request):
    if request.method == 'POST':
        try:
            data = json.loads(request.body)
            user_id_str = data.get('user_id')
            if not user_id_str:
                user = UserProfile.objects.create()
                user_id_str = str(user.user_id)
            else:
                try:
                    user = UserProfile.objects.get(user_id=user_id_str)
                except UserProfile.DoesNotExist:
                    user = UserProfile.objects.create(user_id=user_id_str)

            user.allergies = data.get('allergies', '')
            user.favorite_foods = data.get('favorite_foods', '')
            user.disliked_foods = data.get('disliked_foods', '')
            user.save()
            return JsonResponse({'user_id': str(user.user_id), 'message': 'Preferences saved!'})
        except json.JSONDecodeError:
            return JsonResponse({'error': 'Invalid JSON'}, status=400)
    return JsonResponse({'error': 'Method not allowed'}, status=405)

def get_recommendation(request, user_id):
    try:
        user = UserProfile.objects.get(user_id=user_id)
        prompt = f"allergies: {user.allergies}, favorite foods: {user.favorite_foods}, disliked foods: {user.disliked_foods}"
        ai_recommendation = get_ai_recommendation(prompt)

        RecommendationHistory.objects.create(user=user, recommendation=ai_recommendation)
        return JsonResponse({'recommendation': ai_recommendation})
    except UserProfile.DoesNotExist:
        return JsonResponse({'error': 'User not found'}, status=404)

def get_history(request, user_id):
    try:
        user = UserProfile.objects.get(user_id=user_id)
        history = RecommendationHistory.objects.filter(user=user).order_by('-timestamp')
        history_data = [{'recommendation': h.recommendation, 'timestamp': h.timestamp.isoformat()} for h in history]
        return JsonResponse({'history': history_data})
    except UserProfile.DoesNotExist:
        return JsonResponse({'error': 'User not found'}, status=404)