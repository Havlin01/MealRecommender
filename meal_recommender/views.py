# meal_recommender/views.py
from django.http import HttpResponse, JsonResponse
from django.views.decorators.csrf import csrf_exempt
import json
from .models import UserProfile, RecommendationHistory
import google.generativeai as genai
import os

# Configure the Gemini API with your API key
genai.configure(api_key=os.getenv('GEMINI_API_KEY'))

# Select the Gemini model for text generation
model = genai.GenerativeModel('gemini-2.0-flash')

def get_ai_recommendation(prompt):
    try:
        response = model.generate_content(prompt)
        return response.text.strip()
    except Exception as e:
        print(f"Error during Gemini generation: {e}")
        return "Error generating recommendation using Gemini."
    
@csrf_exempt # For simplicity in this example, handle CSRF properly in production
def delete_account(request, user_id):
    if request.method == 'DELETE':
        try:
            user = UserProfile.objects.get(user_id=user_id)
            user.delete()
            return HttpResponse(status=204) # No Content on successful deletion
        except UserProfile.DoesNotExist:
            return JsonResponse({'error': 'User not found'}, status=404)
    else:
        return JsonResponse({'error': 'Method not allowed'}, status=405)    

@csrf_exempt
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

            user.allergies = data.get('allergies', 'None')
            user.favorite_foods = data.get('favorite_foods', 'None')
            user.disliked_foods = data.get('disliked_foods', 'None')
            user.save()
            return JsonResponse({'user_id': str(user.user_id), 'message': 'Preferences saved!'})
        except json.JSONDecodeError:
            return JsonResponse({'error': 'Invalid JSON'}, status=400)
    return JsonResponse({'error': 'Method not allowed'}, status=405)

def get_recommendation(request, user_id):
    try:
        user = UserProfile.objects.get(user_id=user_id)
        prompt = f"Recommend five different meals for someone with the following preferences: " \
                 f"Allergies: {user.allergies}. Favorite foods: {user.favorite_foods}. " \
                 f"Disliked foods: {user.disliked_foods}. Please give me a numbered list of five distinct meal names."
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