# beanthere
## Contributions
### Yrone Umutesi (25%)
- Created the Navigation Bar for the screens and set up the segues that connected it to all other screens
- Created the User Setting and Edit Settings pages and connected them to firebase to import the data to and from and change it
- Set up the Storage file in firebase that stores all the user’s profile pictures and updates them whenever user changes it and created a link between firebase and swift for picture upload
### Sujitha Seenivasan (25%)
- Set up Firebase Authentication + created login and create account screens
- Table View that displays the list of cafe profiles
- Search functionality within the table view that allows you to search for a cafe and the segue to click on a profile
### Sarah Fedorchak (25%)
- The UI for the Cafe Profile screen and did the backend for that screen which included fetching data about the coffee shops from Firestore
- The UI for the Coffee Search page which included making custom cell for the Table View that displays the list of cafe profiles
### Eshi Kohli (25%)
- Added UI to change password on Login screen and User Settings screen which will send a password reset email to the user and update their password in Firebase Authentication
- Wrote Python script to fill in Firestore Database with coffee shops and their information (name, address, image, etc.) from Yelp Search API and added manual descriptions for cafes

## Deviations
- We did not include ratings (1-5 bean scale) and tags based off of the user reviews because we will be working on the Coffee Connect and BrewLog in the next release which is where the users give their ratings. For now, we added placeholders for that information based on 
- We anticipated getting descriptions from the Yelp / Google API but it was paid or did not exist, so we had to manually add in the descriptions to Firestore as discussed with Professor Bulko.
As discussed with professor Bulko we changed the edit page, instead of it being a pop up for one field, users are able to change and update all the fields at once.
