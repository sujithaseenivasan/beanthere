import requests
import firebase_admin
from firebase_admin import credentials, firestore

cred = credentials.Certificate('/Users/Eshi/Downloads/beanthere-9e00b-firebase-adminsdk-fbsvc-6b58b45e9b.json')
firebase_admin.initialize_app(cred)
db = firestore.client()

API_KEY = 'rtTKHqEj55rTTO22Y-RE3mo0O91HYLFH85Hd04PKmJBdNbxkqkgNhYMrTy2_3vAQ2Szk6u2MNNl8sFBxjh2SbcyS6eNkIu8fD9Ya-Z6JG237Kj_comkWO3iyeunHZXYx'
API_HOST = 'https://api.yelp.com'
SEARCH_PATH = '/v3/businesses/search'
BUSINESS_PATH = '/v3/business/'

def request(api_key, url_params=None):
    url_params = url_params or {}
    url = f"{API_HOST}{SEARCH_PATH}"
    headers = {
        'Authorization': f"Bearer {api_key}"
    }
    response = requests.get(url, headers=headers, params=url_params)
    return response.json()


def search(api_key, term, location):
    url_params = {
        'term': term.replace(' ', '+'),
        'location': location.replace(' ', '+'),
        'limit': 5  # Adjust limit as needed
    }
    return request(api_key, url_params)


def get_business(api_key, business_id):
    url = f"{API_HOST}{BUSINESS_PATH}{business_id}"
    return request(api_key, url)


def save_to_firestore(coffee_shops, api_key):
    for shop in coffee_shops:
        # details = get_business(api_key, shop['id'])
        # description = details.get('description', 'No description available.')
        # image_url = details.get('image_url', 'No image available.')
        price = shop.get('price', 'N/A')
        doc_ref = db.collection('coffeeShops').document(shop['id'])
        doc_ref.set({
            'name': shop['name'],
            'address': ', '.join(shop['location']['display_address']),
            'city': shop['location']['city'],
            'image_url': shop['image_url'],
            'price': price,
            'phone': shop['display_phone'],
            'reviews': [],
            'topTags': [],
            'avgRating': None
        })


term = 'Coffee'
location = 'Austin, TX'
coffee_shops = search(API_KEY, term, location).get('businesses', [])

if coffee_shops:
    print(f"Found {len(coffee_shops)} coffee shops.")
    save_to_firestore(coffee_shops, API_KEY)
else:
    print("No coffee shops found.")