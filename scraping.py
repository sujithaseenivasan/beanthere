import requests
import firebase_admin
from firebase_admin import credentials, firestore

cred = credentials.Certificate('/Users/Eshi/Downloads/beanthere-9e00b-firebase-adminsdk-fbsvc-6b58b45e9b.json')
firebase_admin.initialize_app(cred)
db = firestore.client()

YELP_API_KEY = 'rtTKHqEj55rTTO22Y-RE3mo0O91HYLFH85Hd04PKmJBdNbxkqkgNhYMrTy2_3vAQ2Szk6u2MNNl8sFBxjh2SbcyS6eNkIu8fD9Ya-Z6JG237Kj_comkWO3iyeunHZXYx'
GOOGLE_API_KEY = 'AIzaSyCpUfuhulfHNJzDKQDd67i_CLQEjXynPPU'
API_HOST = 'https://api.yelp.com'
SEARCH_PATH = '/v3/businesses/search'
BUSINESS_PATH = '/v3/business/'


# def get_google_place_id(google_api_key, name, address):
#     query = f"{name} {address}"
#     url = "https://maps.googleapis.com/maps/api/place/findplacefromtext/json"
#     params = {
#         "input": query,
#         "inputtype": "textquery",
#         "fields": "place_id",
#         "key": google_api_key
#     }
#     response = requests.get(url, params=params)
#     data = response.json()
#     candidates = data.get('candidates')
#     if candidates:
#         print("found candidates")
#         return candidates[0].get('place_id')
#     return None

def get_google_place_id(google_api_key, name, address):
    # use geocoding api
    query = f"{name} {address}"
    url = "https://maps.googleapis.com/maps/api/geocode/json"
    params = {
        "address": query,
        "key": google_api_key
    }
    response = requests.get(url, params=params)
    data = response.json()
    if data.get('status') == "OK" and data.get('results'):
        return data['results'][0].get('place_id')
    print("didn't work")
    return None


def get_horizontal_photo_url(google_api_key, place_id, maxwidth=800):
    """Gets a horizontal photo URL from a place's details."""
    details_url = "https://maps.googleapis.com/maps/api/place/details/json"
    params = {
        "place_id": place_id,
        "fields": "photos",
        "key": google_api_key
    }
    response = requests.get(details_url, params=params)
    details = response.json()
    photos = details.get('result', {}).get('photos', [])
    if photos:
        # Look for a horizontal image (width > height)
        for photo in photos:
            if photo.get('width', 0) > photo.get('height', 0):
                photo_reference = photo.get('photo_reference')
                break
        else:
            # If no horizontal photo is found, fallback to the first one
            photo_reference = photos[0].get('photo_reference')
        # Build the URL to retrieve the photo
        photo_url = f"https://maps.googleapis.com/maps/api/place/photo?maxwidth={maxwidth}&photoreference={photo_reference}&key={google_api_key}"
        return photo_url
    return None


def request(yelp_api_key, url_params=None):
    url_params = url_params or {}
    url = f"{API_HOST}{SEARCH_PATH}"
    headers = {
        'Authorization': f"Bearer {yelp_api_key}"
    }
    response = requests.get(url, headers=headers, params=url_params)
    return response.json()


def search(yelp_api_key, term, location):
    url_params = {
        'term': term.replace(' ', '+'),
        'location': location.replace(' ', '+'),
        'limit': 50
    }
    return request(yelp_api_key, url_params)


def get_business(yelp_api_key, business_id):
    url = f"{API_HOST}{BUSINESS_PATH}{business_id}"
    return request(yelp_api_key, url)


def save_to_firestore(coffee_shops, yelp_api_key):
    for shop in coffee_shops:
        # details = get_business(api_key, shop['id'])
        # description = details.get('description', 'No description available.')
        # image_url = details.get('image_url', 'No image available.')
        doc_ref = db.collection('coffeeShops').document(shop['id'])
        yelp_address = ', '.join(shop['location']['display_address'])
        place_id = get_google_place_id(GOOGLE_API_KEY, shop['name'], yelp_address)
        price = shop.get('price', 'N/A')
        if place_id:
            # Get a horizontal image URL from Google Places
            image_url = get_horizontal_photo_url(GOOGLE_API_KEY, place_id)
        else:
            # Fallback to the Yelp image if Google lookup fails
            image_url = shop['image_url']
        doc_ref.set({
            'name': shop['name'],
            'address': yelp_address,
            'city': shop['location']['city'],
            'image_url': image_url,
            'price': price,
            'phone': shop['display_phone'],
            'reviews': [],
            'topTags': [],
            'avgRating': None,
            'description': ""
        })


term = 'Coffee'
location = 'Austin, TX'
coffee_shops = search(YELP_API_KEY, term, location).get('businesses', [])

if coffee_shops:
    print(f"Found {len(coffee_shops)} coffee shops.")
    save_to_firestore(coffee_shops, YELP_API_KEY)
else:
    print("No coffee shops found.")