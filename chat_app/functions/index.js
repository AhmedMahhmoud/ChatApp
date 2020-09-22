const functions = require('firebase-functions');

exports.myFunction = functions.firestore
  .document('chats//{messages}')
  .onCreate((snapshot, context) => {
console.log(snapshot.data());


       /* ... */ });