# SkyShelf

NASA Space Gallery with Personal Notes. An iOS app built with SwiftUI for the Mobile Computing open-ended project.

Users sign up, browse NASA's Astronomy Picture of the Day (APOD), save pictures to a personal favorites shelf, and write their own notes on them.

## Features

- Register, login and logout with Firebase Authentication (email and password)
- Change password from the Profile screen (current password, new password, confirm password)
- Today's Astronomy Picture of the Day shown as a large photo card
- Gallery of the last 10 days, loaded in one request
- Browse a past date with a date picker (from 1995-06-16 up to today)
- Detail screen with the image, title, date, credit, HD link and full explanation
- Video days show a preview picture and an "Open video" link
- Save or remove favorites (Cloud Firestore)
- Personal shelf with live updates, title search and swipe to delete
- Add, edit and delete a note on each favorite
- Error messages with a Retry button (offline, too many requests, bad date)
- Logout confirmation, and the Firestore listener is stopped before signing out

## Tech Stack

- Swift and SwiftUI (iOS 16 or later)
- NavigationStack, NavigationLink, @State, @Binding, @StateObject, @EnvironmentObject, ObservableObject
- Firebase Authentication and Cloud Firestore (Swift Package Manager)
- URLSession with async/await, Decodable and JSONDecoder (JSON parsing)
- Pictures are downloaded with URLSession and shown with loading, success and failure states

## Data Source

The app uses the NASA Science APOD API:

```
https://science.nasa.gov/wp-json/wp/v2/apod-basic
```

- No API key is needed.
- Results come back newest first as a JSON array and work in pages (`per_page` and `page`).
- The older `api.nasa.gov/planetary/apod` endpoint is being retired, so the app uses this one.
- The text in the new API contains HTML tags, so the app cleans it while decoding.
- For image days the `url` field is a web page, and the real picture is in `hdurl`, so the app picks the field that points to an image file.

## Firestore Structure

Path: `users/{uid}/favorites/{date}`

| Field | Type | Description |
|---|---|---|
| title | String | Picture title |
| imageURL | String | Picture or video preview URL |
| explanation | String | NASA description |
| mediaType | String | "image" or "video" |
| note | String | User note (empty if none) |
| savedAt | Timestamp | When it was saved |

The document ID is the date, so a picture cannot be saved twice.

Security rules (only the signed-in owner can read or write their own data):

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{uid}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == uid;
    }
  }
}
```

## Setup

1. Clone the repository and open `SkyShelf/SkyShelf.xcodeproj` in Xcode.
2. Create a Firebase project. Add an iOS app with the same bundle identifier as the Xcode target, and place `GoogleService-Info.plist` next to `SkyShelfApp.swift` (tick the SkyShelf target).
3. In Firebase, enable Authentication > Email/Password, create a Firestore database, and publish the rules above.
4. Make sure FirebaseAuth and FirebaseFirestore are linked under target > General > Frameworks, Libraries, and Embedded Content.
5. Select an iPhone simulator (iOS 16 or later) and press Run.

No NASA key is needed.

## How to Use

1. Tap **New here? Sign Up**, enter an email and a password of at least 6 characters, and sign up.
2. On the home screen, tap the big photo card to open today's picture, or pick a date and tap **View**.
3. Open any picture and tap the heart to save it.
4. Tap **My Shelf** to see your favorites. Search by title, tap a card to write a note, and swipe left to delete.
5. Tap the person icon to open Profile and change your password.
6. Tap **Logout** to sign out.

## Testing Checklist

- Sign up, log out and log in; wrong password and invalid input show messages
- Today's picture and the 10-day gallery load; Retry works after going offline
- Detail screen works for image days and video days
- Heart adds and removes a favorite; rapid taps never create duplicates
- Shelf search, swipe to delete and the empty state work
- Notes can be added, edited and deleted
- Password change: wrong current password, mismatched confirmation and a successful change
- A second account sees only its own favorites

## Troubleshooting

- **Missing or insufficient permissions:** publish the Firestore rules above.
- **Crash about GoogleService-Info.plist:** the plist is missing or not added to the SkyShelf target.
- **No such module 'FirebaseAuth':** add FirebaseAuth and FirebaseFirestore under target > General > Frameworks, Libraries, and Embedded Content.
- **Pictures show a grey box:** check the internet connection of the simulator.
- **GameKit or GameController build errors in FirebaseAuth:** can happen with a beta Xcode. Use a release Xcode, or empty `FIRGameCenterAuthProvider.m` in the Firebase package checkout (the app does not use Game Center).
