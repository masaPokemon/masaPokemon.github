// Please see this file for the latest firebase-js-sdk version:
// https://github.com/firebase/flutterfire/blob/master/packages/firebase_core/firebase_core_web/lib/src/firebase_sdk_version.dart
importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyD_ddEwE9Cy9rvh7Rdf5ddVBAY8aEKj9cM",
  authDomain: "seat-change-optimization.firebaseapp.com",
  databaseURL: "https://seat-change-optimization-default-rtdb.firebaseio.com",
  storageBucket: "seat-change-optimization.firebasestorage.app",
  projectId: "seat-change-optimization",
  appId: "1:416064751674:web:a2808bdfffe75a012ccd03",
  messagingSenderId: "416064751674",
  measurementId: "G-Q6TSN9L1TN"
  projectId: "...",
  storageBucket: "...",
  messagingSenderId: "...",
  appId: "...",
});

const messaging = firebase.messaging();

// Optional:
messaging.onBackgroundMessage((message) => {
  console.log("onBackgroundMessage", message);
});
