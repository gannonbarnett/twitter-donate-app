// The Cloud Functions for Firebase SDK to create Cloud Functions and setup triggers.
const functions = require('firebase-functions');

// The Firebase Admin SDK to access the Firebase Realtime Database.
const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);

//var Twit = require('twit')
	
exports.twitterFunction = functions.https.onRequest((req, res) => {

	//get active handles
	var handles = []; 
	
	var query = admin.database().ref('/activeHandles'); 
	return query.once('value').then (function(querySnapshot) {
       	 querySnapshot.forEach(function (snapshot) {
       		const handle = snapshot.key;
			const lastID = snapshot.val().lastID; 
			getTweetFromHandle(handle, lastID); 
       	})
       	return; 
   }); 
});

function getTweetFromHandle(handle, lastID) {
	console.log("retrieving last tweet from @" + handle + " past " + lastID); 
	
	var Twit = require('twit')
	
	var T = new Twit({
	  consumer_key:        'c18jxuX7mpK57zNpT5sA3wLRm',
	  consumer_secret:      '3xr1H69nY0bvCpHsSCSOfAGDXqHrWh20wnW0BtJC0U8Z3xsSi9',
	  access_token:         '2802629606-5QcJ8pZ3zyrq9KSwx4YGhirCKyopVo4nejGICbf',
	  access_token_secret:  'q1XEzrEV1Ufewfkw1ZbrA74Ty5K6PreWQOyf4Zv7FDQTu',
	})
	
	var params = {'screen_name': handle, 
					'count': 1, 
					'tweet_mode': 'extended'}
	
	T.get('statuses/user_timeline', params, function(err, data, response) {
		if (err) {
			console.log(err); 
			return;
		}
		const tweet_lastID = data[0]['id'];
		
		if (tweet_lastID !== lastID) {
			console.log("new tweet found from @" + handle); 
			const tweet_date = data[0]['created_at']; 
			const tweet_text = data[0]['full_text']; 

			admin.database().ref('activeHandles/' + handle + '/lastID').set(tweet_lastID); 
			admin.database().ref('activeHandles/' + handle + '/lastTweet').set(tweet_text); 
			admin.database().ref('activeHandles/' + handle + '/lastTweet_time').set(tweet_date); 
			
			var query = admin.database().ref('/activeHandles/' + handle + '/fundraisers'); 
			return query.once('value').then (function(querysnapshot) {
    			querysnapshot.forEach(function (snapshot)  {
					//for each fundraiser, check for keywords
					const fundraiser = snapshot.key;
					updateFundraiser(fundraiser, tweet_text); 
				})
				return true; 
   			}); 
   		
		} else {
			console.log("no new tweets from @" + handle); 
			return; 
		}
		
	})

}

function updateFundraiser(fundraiser, tweet_text) {
	console.log("updated " + fundraiser + " based on tweet: \"" + tweet_text + "\""); 
	
	var query = admin.database().ref('/fundraisers/' + fundraiser + '/keywords'); 
	return query.once('value').then (function(querysnapshot) {
    	querysnapshot.forEach(function (keywordSnapshot)  {
			//iterate through keywords
			const keyword = keywordSnapshot.key; 
			if (tweet_text.indexOf(keyword) >= 0) {
				console.log(fundraiser + ": mention of keyword: " + keyword); 
				
				keywordSnapshot.forEach(function (usersSnapshot) {
					//iterate through users to add points to 
					addPointsToUser(fundraiser, usersSnapshot.val()); 
				});
			}else {
				console.log(fundraiser + ": no mention of keyword: " + keyword); 
			}
		})
		return true; 
	}); 
}

function addPointsToUser(fundraiser, user) {
	console.log(fundraiser + ": adding point to user: " + user); 
	
	var query = admin.database().ref('/fundraisers/' + fundraiser + '/user_statistics/' + user); 
	
	return query.once('value').then( function(querySnapshot) {
		console.log('adding value');
		admin.database().ref('/fundraisers/' + fundraiser + '/user_statistics/' + user).set(querySnapshot.val() + 1);		
		return true; 
	}); 
}









