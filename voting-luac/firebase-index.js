'use strict';

// Contest vote database interface
// Receives votes sent through voting-booth.lua

const functions = require('firebase-functions');
const admin = require('firebase-admin');
const app = require('express')();

var serviceAccount = require("./permissions.json");
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://pandorabox-github.firebaseio.com"
});
const db = admin.database();

function contestVote(contestId, name, answer, callback) {
  db.ref('contests/' + contestId + '/' + name).set({
    answer: answer
  },callback);
}

app.get('/:contest/:token/:name/:answer', (req, res) => {
  (async () => {
    if (req.params.token === 'JustWhateverStaticSecretKey') {
      contestVote(
        req.params.contest,
        req.params.name,
        req.params.answer,
        (error) => {
          if (error) {
            return res.status(200).send(response);
          } else {
            return res.status(500).send(error);
          }
        }
      );
    } else {
      return res.status(403).send("No access\n")
    }
  })();
});

exports.vote = functions.https.onRequest(app);
